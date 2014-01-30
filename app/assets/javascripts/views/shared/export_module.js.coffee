class Visio.Views.ExportModule extends Backbone.View

  className: 'overview-overlay'

  template: HAML['shared/export_module']

  events:
    'change figcaption input': 'onSelectionChange'
    'click .export': 'onClickExport'

  initialize: (options) ->
    $(document).scrollTop(0)

    @config =
      margin:
        top: 30
        bottom: 30
        left: 90
        right: 80
      width: 600
      height: 300
      isExport: true
      figureId: @model.get('figure_id')

    $.subscribe "select.#{@model.get('figure_id')}", @select

  render: ->

    datum.index = i for datum, i in @model.get 'data'

    @$el.html @template( model: @model.toJSON() )
    @config.selection = d3.select(@el).select('.export-figure figure')
    @figure = @model.figure()(@config)


    @figure.data @model.get('data')

    @figure()
    @

  onSelectionChange: (e) ->
    e.preventDefault()
    $target = $(e.currentTarget)
    d = _.find @model.get('data'), (d) ->
      d.index == +$target.val()

    $.publish "select.#{@model.get('figure_id')}.figure", [d]


  select: (e, d) =>
    $input = @$el.find("#datum-#{d.index}")
    checked = $input.is(':checked')

    # Toggle if it's check or not
    $input.prop 'checked', not checked

  onClickExport: ->
    statusCodes =
      200: =>
        window.location.assign @model.pdfUrl()
      504: ->
       console.log "Shit's beeing wired"
      503: (jqXHR, textStatus, errorThrown) =>
        wait = parseInt jqXHR.getResponseHeader('Retry-After')
        setTimeout =>
          $.ajax
            url: @model.pdfUrl()
            statusCode: statusCodes
        , wait * 3000

    formArray = @$el.find('.export-settings form').serializeArray()
    _.each formArray, (formObj) => @model.set formObj.name, formObj.value

    @model.save().then =>
      $.ajax
        url: @model.pdfUrl()
        statusCode: statusCodes

  close: ->
    $.unsubscribe "select.#{@model.get('figure_id')}"
    @figure.unsubscribe()
    @unbind()
    @remove()

