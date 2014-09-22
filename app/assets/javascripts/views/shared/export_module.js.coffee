class Visio.Views.ExportModule extends Backbone.View

  className: 'page-overlay export-module'

  template: HAML['shared/export_module']

  events:
    'change figcaption input': 'onSelectionChange'
    'click .pdf': 'onClickPdf'
    'click .email': 'onClickEmail'
    'click .png': 'onClickPng'
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
      $.subscribe "active.#{@figure.figureId()}", @select
      @selectableData = @figure.selectableData()

  render: ->

    @$el.html @template
      model: @model.toJSON()
      selectableData: @selectableData
      selectableLabel: @figure.selectableLabel

    @$el.find('.export-figure figure').html @figure.el
    if @config.selectable or @config.previewable
      @figure.render()
    else
      @figure.$el.html "<img src=\"/assets/previews/#{@figure.type.name}.png\" />"
    @$el.css 'height', $(document).height()
    @

  onSelectionChange: (e) ->
    e.preventDefault()
    $target = $(e.currentTarget)
    d = _.find @selectableData, (d, i) ->
      i == +$target.val()

    unless d
      console.warn "No element found. Returning"
      return

    $.publish "active.#{@figure.figureId()}.figure", [d]


  select: (e, d, i) =>
    $input = @$el.find("#datum-#{i}")
    checked = $input.is(':checked')

    # Toggle if it's check or not
    $input.prop 'checked', not checked

  buildModule: =>
    formArray = @$el.find('form').serializeArray()
    _.each formArray, (formObj) => @model.set formObj.name, formObj.value

    selected = _.map @$el.find('figcaption input[type="checkbox"]:checked'), (ele) -> $(ele).attr('data-id')
    @model.get('figure_config').selected = selected

  onClickEmail: ->
    return if @loadingPdf.get 'loading'
    NProgress.start()
    @buildModule()
    @model.save().done =>
      $.ajax
        method: 'GET'
        url: @model.emailUrl()
        success: (resp) =>
          NProgress.done()
          new Visio.Views.Success
            title: "PDF Report"
            description: "Report is being sent to #{resp.email}"
          @loadingPdf.set 'loading', false
        error: =>
          new Visio.Views.Error
            title: "Error generating PDF"
          NProgress.done()
          @loadingPdf.set 'loading', false

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
        , wait * 6000

    @buildModule()
    @model.save().done =>
      $.ajax
        url: @model.pdfUrl()
        statusCode: statusCodes

  onClickPng: =>
    @buildModule()
    @$el.find('svg').parent().inlinify()

    html = d3.select(@el).select('svg')
      .attr('version', 1.1)
      .attr("xmlns", "http://www.w3.org/2000/svg")
      .node()

    svgenie.save html, { name: 'graph.png' }

  onClose: ->
    @close()

  close: ->
    $.unsubscribe "active.#{@figure.figureId()}" if @config.selectable
    @figure.unsubscribe() if @figure?.unsubscribe?
    @unbind()
    @remove()

