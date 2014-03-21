class Visio.Views.ExportModule extends Backbone.View

  className: 'page-overlay export-module'

  template: HAML['shared/export_module']

  events:
    'change figcaption input': 'onSelectionChange'
    'click .pdf': 'onClickPdf'
    'click .close': 'onClose'

  initialize: (options) ->
    $(document).scrollTop(0)
    @config = @model.get 'figure_config'
    @loadingPdf = new Backbone.Model
      loading: false

    @loadingPdf.on 'change:loading', =>
      @$el.find('.pdf').toggleClass 'disabled'

    @figure = @model.figure @config

    if @config.selectable
      $.subscribe "select.#{@figure.figureId()}", @select
      @filtered = @figure.filtered @figure.dataAccessor()

  render: ->

    @$el.html @template( model: @model.toJSON(), filtered: @filtered )
    @$el.find('.export-figure figure').html @figure.el
    if @config.selectable
      @figure.render()
    else
      @figure.$el.html @figure.type.human
    @$el.css 'height', $(document).height()
    @

  onSelectionChange: (e) ->
    e.preventDefault()
    $target = $(e.currentTarget)
    d = _.find @filtered, (d, i) ->
      i == +$target.val()

    unless d
      console.warn "No element found. Returning"
      return

    $.publish "select.#{@figure.figureId()}.figure", [d]


  select: (e, d, i) =>
    $input = @$el.find("#datum-#{i}")
    checked = $input.is(':checked')

    # Toggle if it's check or not
    $input.prop 'checked', not checked

  onClickPdf: ->
    return if @loadingPdf.get 'loading'
    @loadingPdf.set 'loading', true
    NProgress.start()
    statusCodes =
      200: =>
        NProgress.done()
        window.location.assign @model.pdfUrl()
        @loadingPdf.set 'loading', false
      504: =>
        new Visio.Views.Error
          title: "Error generating PDF"
        NProgress.done()
        @loadingPdf.set 'loading', false
      503: (jqXHR, textStatus, errorThrown) =>
        wait = parseInt jqXHR.getResponseHeader('Retry-After')
        NProgress.inc()
        setTimeout =>
          $.ajax
            url: @model.pdfUrl()
            statusCode: statusCodes
        , wait * 7000

    formArray = @$el.find('form').serializeArray()
    _.each formArray, (formObj) => @model.set formObj.name, formObj.value

    selected = _.map @$el.find('figcaption input[type="checkbox"]:checked'), (ele) -> $(ele).attr('data-id')
    @model.get('figure_config').selected = selected

    @model.save().done =>
      $.ajax
        url: @model.pdfUrl()
        statusCode: statusCodes

  onClose: ->
    @close()

  close: ->
    $.unsubscribe "select.#{@figure.figureId()}" if @config.selectable
    @figure.unsubscribe() if @figure?.unsubscribe?
    @unbind()
    @remove()

