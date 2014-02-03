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
    # Call super
    Visio.Views.AccordionIndexView.prototype.initialize.apply @, [options]

    @config =
      margin:
        top: 10
        bottom: 80
        left: 120
        right: 40
      width: 650
      height: 300
      figureId: @bmySummaryFigureId()

    Visio.FigureInstances[@bmySummaryFigureId()] = Visio.Figures.bmy @config

  render: (isRerender) ->
    # Call super
    Visio.Views.AccordionIndexView.prototype.render.apply @, [isRerender]

    unless isRerender
      @$el.find('.summary-figure').html Visio.FigureInstances[@bmySummaryFigureId()].el()

    @drawFigures()
    @

  drawFigures: ->
    data = []
    parameters = Visio.manager.selected(Visio.manager.get('aggregation_type')).models
    _.each parameters, (model) ->
      data = data.concat model.selectedBudgetData(true).models

    Visio.FigureInstances[@bmySummaryFigureId()].data data
    Visio.FigureInstances[@bmySummaryFigureId()]()

  sort: (parameterA, parameterB) ->
    0

  bmySummaryFigureId: ->
    "bmy-summary"
