class Visio.Views.BsyView extends Backbone.View

  template: HAML['modules/bsy']

  className: 'module'

  id: 'bsy'

  initialize: (options) ->
    @config =
      width: 800
      height: 360
      margin:
        top: 40
        bottom: 30
        left: 90
        right: 80

    @figure = new Visio.Figures.Bsy @config
    @filterBy = new Visio.Views.FilterBy figure: @figure
    @queryBy = new Visio.Views.QueryBy figure: @figure

  render: (isRerender) ->

    if !isRerender
      @$el.html @template
        figureId: @figure.figureId()

      @$el.find('figure').html @figure.el
      @$el.find('.header-buttons').append @filterBy.render().el
      @$el.find('.header-buttons').append @queryBy.render().el

      @$el.find('.slider').slider
        animate: true
        slide: @onSlide
        stop: @onStop
        min: 0


    human = Visio.Utils.parameterByPlural(Visio.manager.get('aggregation_type')).human
    @queryBy.$el.find('input').attr 'placeholder', "Search for a #{human}"

    @drawFigures()
    @

  drawFigures: =>
    parameters = Visio.manager.selected(Visio.manager.get('aggregation_type'))
    @figure.collectionFn parameters
    max = parameters.length
    @figure.render()

    # Make sure something is there
    unless @figure.tooltip.hasRendered()
      $.publish "hover.#{@figure.cid}.figure", 0

    @$el.find('.slider').slider 'option', 'max', max - 1
    @$el.find('.slider').attr('data-max', max)

  onStop: (e, ui) =>
    $.publish "mouseout.#{@figure.cid}.figure", ui.value

  onSlide: (e, ui) =>
    $.publish "hover.#{@figure.cid}.figure", ui.value
    @$el.find('.slider .ui-slider-handle').attr 'data-value', ui.value + 1
