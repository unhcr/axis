class Visio.Views.BsyView extends Visio.Views.Module

  @include Visio.Mixins.Narratify

  template: HAML['modules/bsy']

  className: 'module'

  id: 'bsy'

  initialize: (options) ->
    @config =
      width: @figureWidth true
      height: 375
      margin:
        top: 85
        bottom: 30
        left: 115
        right: 80

    @figure = new Visio.Figures.Bsy @config
    @narratify @figure

    @filterBy = new Visio.Views.FilterBy figure: @figure
    @queryBy = new Visio.Views.QueryBy figure: @figure
    @sortBy = new Visio.Views.Dropdown
      title: 'Sort By'
      data: [
          { label: 'Comprehensive Budget', value: 'total', checked: true },
          { label: 'OL Budget', value: Visio.Scenarios.OL },
          { label: 'AOL Budget', value: Visio.Scenarios.AOL },
        ]
      callback: (value, data) =>
        @figure.sortAttribute = value
        @figure.render()

    $.subscribe "hover.#{@figure.cid}.figure", (e, idxOrDatum) =>
      if _.isNumber idxOrDatum
        value = idxOrDatum
      else
        value = @figure.findBoxByDatum(idxOrDatum).idx

      @$el.find('.slider').slider 'value', value
      @$el.find('.slider .ui-slider-handle').attr 'data-value', value + 1


  render: (isRerender) ->

    if !isRerender
      @$el.html @template
        figureId: @figure.figureId()

      @$el.find('figure').html @figure.el
      @$el.find('.header-buttons').append @filterBy.render().el
      @$el.find('.header-buttons').append @sortBy.render().el
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

    @$el.find('.slider').slider 'option', 'max', max - 1
    @$el.find('.slider').attr('data-max', max)

  onStop: (e, ui) =>
    $.publish "mouseout.#{@figure.cid}.figure", ui.value

  onSlide: (e, ui) =>
    $.publish "hover.#{@figure.cid}.figure", ui.value
    @$el.find('.slider .ui-slider-handle').attr 'data-value', ui.value + 1
