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
        bottom: 80
        left: 120
        right: 40
      width: 650
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
    Visio.FigureInstances[@bmyFigureId()].data @model.selectedBudgetData(true).models
    Visio.FigureInstances[@bmyFigureId()]()

  bmyFigureId: =>
    "bmy-#{@model.id}"

  removeInstances: =>
    delete Visio.FigureInstances[@bmyFigureId()]

