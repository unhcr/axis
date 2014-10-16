class Visio.Views.BsyView extends Visio.Views.Module

  @include Visio.Mixins.Narratify
  @include Visio.Mixins.Slidify

  template: HAML['modules/bsy']

  className: 'module'

  id: 'bsy'

  initialize: (options) ->
    @config =
      width: @figureWidth true
      height: 435
      margin:
        top: 85
        bottom: 80
        left: 115
        right: 80

    @figure = new Visio.Figures.Bsy @config
    @narratify @figure

    @filterBy = new Visio.Views.FilterBy figure: @figure
    @queryBy = new Visio.Views.QueryBy figure: @figure
    @sortBy = new Visio.Views.Dropdown
      className: 'sort-by'
      title: 'Sort By'
      data: [
          { label: 'Comprehensive Budget', value: 'total', checked: true },
          { label: 'OL Budget', value: Visio.Scenarios.OL },
          { label: 'AOL Budget', value: Visio.Scenarios.AOL },
          { label: '% of OP', value: 'percent' },
        ]
      callback: (value, data) =>
        @figure.sortAttribute = value
        @figure.render()

    @initSlider @figure

  render: (isRerender) ->

    if !isRerender
      @$el.html @template
        figureId: @figure.figureId()

      @$el.find('figure').html @figure.el
      @$el.find('.header-buttons').append @filterBy.render().el
      @$el.find('.header-buttons').append @sortBy.render().el
      @$el.find('.header-buttons').append @queryBy.render().el
      @renderSlider()



    human = Visio.Utils.parameterByPlural(Visio.manager.get('aggregation_type')).human
    @queryBy.$el.find('input').attr 'placeholder', "Search for a #{human}"

    @drawFigures()
    @

  drawFigures: =>
    parameters = Visio.manager.selected(Visio.manager.get('aggregation_type'))
    @figure.collectionFn parameters
    max = @figure.getMax()
    @figure.render()

    @setSliderMax max
