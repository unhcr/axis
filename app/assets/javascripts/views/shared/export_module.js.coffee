class Visio.Views.ExportModule extends Backbone.View

  className: 'overview-overlay export-module'

  template: HAML['shared/export_module']

  events:
    'change figcaption input': 'onSelectionChange'
    'click .export': 'onClickExport'
    'click .close': 'onClose'

  initialize: (options) ->
    $(document).scrollTop(0)
    @config = @model.get 'figure_config'

    $.subscribe "select.#{@config.figureId}", @select

  render: ->


    @figure = @model.figure()(@config)

    @filtered = @figure.filtered @config.data

    @$el.html @template( model: @model.toJSON(), filtered: @filtered )
    @$el.find('.export-figure figure').html @figure.el()
    @figure()
    @

  onSelectionChange: (e) ->
    e.preventDefault()
    $target = $(e.currentTarget)
    d = _.find @filtered, (d, i) ->
      i == +$target.val()

    unless d
      console.warn "No element found. Returning"
      return

    $.publish "select.#{@config.figureId}.figure", [d]


  select: (e, d, i) =>
    $input = @$el.find("#datum-#{i}")
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

  onClose: ->
    @close()
    Visio.router.navigate '/' + @model.get 'figure_type', { trigger: true }

  close: ->
    $.unsubscribe "select.#{@model.get('figure_id')}"
    @figure.unsubscribe() if @figure?
    @unbind()
    @remove()

