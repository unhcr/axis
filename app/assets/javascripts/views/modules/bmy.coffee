class Visio.Views.BmyView extends Visio.Views.AccordionIndexView

  showView: (options) -> new Visio.Views.BmyShowView(options)

  id: 'bmy'

  events:
    'click .js-parameter': 'onClickParameter'
    'transitionend': 'onTransitionEnd'
    'MSTransitionEnd': 'onTransitionEnd'
    'webkitTransitionEnd': 'onTransitionEnd'
    'oTransitionEnd': 'onTransitionEnd'

  initialize: (options) ->
    super options

    config =
      margin:
        top: 90
        bottom: 90
        left: 150
        right: 80
      width: @figureWidth true
      height: 600

    @figure = new Visio.Figures.BmySummary config

    @narratify @figure

  render: (isRerender) ->
    super isRerender

    unless isRerender
      @$el.find('.summary-figure').html @figure.el
      @$el.find('.summary-figure .header-buttons').append (new Visio.Views.FilterBy({ figure: @figure, })).render().el

    @drawFigures()
    @

  drawFigures: ->
    data = []
    parameters = Visio.manager.selected(Visio.manager.get('aggregation_type'))

    @figure.collectionFn parameters
    groupBy = "#{Visio.Utils.parameterByPlural(Visio.manager.get('aggregation_type')).singular}_id"

    @figure.filters.get('group_by').filter groupBy, true, { silent: true }
    @figure.render()

  sort: (parameterA, parameterB) ->
    dataA = parameterA.selectedBudgetData(Visio.Constants.ANY_YEAR)
    dataB = parameterB.selectedBudgetData(Visio.Constants.ANY_YEAR)

    if dataA.length > 0 and dataB.length > 0
      if parameterA.toString() < parameterB.toString()
        -1
      else if parameterA.toString() > parameterB.toString()
        1
      else
        0
    else
      dataB.length - dataA.length
