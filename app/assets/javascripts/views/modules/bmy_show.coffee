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

    @figure = new Visio.Figures.Bmy @config
    Visio.FigureInstances[@figure.figureId()] = @figure

  render: (isRerender) ->

    unless isRerender
      @$el.html @template( parameter: @model, figureId: @figure.figureId() )
      @$el.find('.bmy-figure').html @figure.el
      @$el.find('.figure-header').html (new Visio.Views.FilterBy({ figure: @figure, })).render().el
    @drawFigures()
    @


  drawFigures: ->
    @figure.dataFn @model.selectedBudgetData(true).models
    @figure.render()

  removeInstances: =>
    delete Visio.FigureInstances[@figure.figureId()]

