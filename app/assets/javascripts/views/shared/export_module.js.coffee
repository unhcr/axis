class Visio.Views.ExportModule extends Backbone.View

  @include Visio.Mixins.Slidify

  className: 'page-overlay export-module'

  template: HAML['shared/export_module']

  events:
    'change figcaption input': 'onSelectionChange'
    'click .pdf': 'onClickPdf'
    'click .email': 'onClickEmail'
    'click .png': 'onClickPng'
    'click .close': 'onClose'

  initialize: (options) ->
    $(document).scrollTop 0
    @config = @model.get 'figure_config'
    @loadingEmail = new Backbone.Model
      loading: false

    @loadingEmail.on 'change:loading', =>
      @$el.find('.email').toggleClass 'disabled'

    @config.width = Visio.Constants.EXPORT_WIDTH
    @config.height = Visio.Constants.EXPORT_HEIGHT

    @figure = @model.figure @config

    if @figure.type == Visio.FigureTypes.BSY or @figure.type == Visio.FigureTypes.ISY
      @initSlider @figure

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

    # Need to render slider
    if @figure.type == Visio.FigureTypes.BSY or @figure.type == Visio.FigureTypes.ISY
      @renderSlider()
      @setSliderMax @figure.getMax()

    @$el.css 'height', $(document).height()
    @$el.find('.email, .png').tipsy
      className: 'tipsy-black'
      trigger: 'hover'
      offset: 30
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
    return if @loadingEmail.get 'loading'
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
          @loadingEmail.set 'loading', false
          @close()
        error: =>
          new Visio.Views.Error
            title: "Error generating PDF"
          NProgress.done()
          @loadingEmail.set 'loading', false
          @close()

  onClickPng: =>
    @buildModule()

    $svg = @figure.getPNGSvg()

    $svg.parent().inlinify()



    fn = () =>
      html = d3.select(@el).select('svg')
        .attr('version', 1.1)
        .attr("xmlns", "http://www.w3.org/2000/svg")
        .node()

      svgenie.save html, { name: 'graph.png' }

      @close()

    # wait for final render
    window.setTimeout fn, Visio.Durations.FAST

  onClose: ->
    @close()

  close: ->
    $.unsubscribe "active.#{@figure.figureId()}" if @config.selectable
    @figure.unsubscribe() if @figure?.unsubscribe?
    $(window).scrollTop 0
    $('.tipsy').remove()

    @unbind()
    @remove()

