class Visio.Views.BmyShowView extends Visio.Views.AccordionShowView

  template: HAML['modules/bmy_show']

  className: 'bmy-container accordion-show-container'

  events:
    'click .js-parameter': 'onClickParameter'
    'transitionend': 'onTransitionEnd'
    'MSTransitionEnd': 'onTransitionEnd'
    'webkitTransitionEnd': 'onTransitionEnd'
    'oTransitionEnd': 'onTransitionEnd'

  initialize: (options) ->
    @config =
      margin:
        top: 10
        bottom: 10
        left: 10
        right: 10
      width: 800
      height: 300
      figureId: @bmyFigureId()

    Visio.FigureInstances[@bmyFigureId()] = Visio.Figures.bmy @config

  render: (isRerender) ->

    unless isRerender
      @$el.html @template( parameter: @model, figureId: @bmyFigureId() )
      @$el.find('.bmy-figure').html Visio.FigureInstances[@bmyFigureId()].el()

    @drawFigures()
    @


  drawFigures: ->
    Visio.FigureInstances[@bmyFigureId()].data @model.selectedBudgetData().models
    Visio.FigureInstances[@bmyFigureId()]()

  bmyFigureId: =>
    "bmy-#{@model.id}"

  removeInstances: =>
    delete Visio.FigureInstances[@bmyFigureId()]

