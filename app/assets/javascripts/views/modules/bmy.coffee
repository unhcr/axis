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

    @config =
      margin:
        top: 40
        bottom: 80
        left: 120
        right: 40
      width: 800
      height: 450

    @figure = new Visio.Figures.BmySummary @config

  render: (isRerender) ->
    super isRerender

    unless isRerender
      @$el.find('.summary-figure').html @figure.el
      @$el.find('.summary-figure .header-buttons').append (new Visio.Views.FilterBy({ figure: @figure, })).render().el

    @drawFigures()
    @

  drawFigures: ->
    data = []
    parameters = Visio.manager.selected(Visio.manager.get('aggregation_type')).models
    _.each parameters, (model) ->
      data = data.concat model.selectedBudgetData(Visio.Constants.ANY_YEAR).models

    @figure.collectionFn new Visio.Collections.Budget(data)
    @figure.groupBy = "#{Visio.Utils.parameterByPlural(Visio.manager.get('aggregation_type')).singular}_id"
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
