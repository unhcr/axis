class Visio.Views.IcmyShowView extends Visio.Views.AccordionShowView

  template: HAML['modules/icmy_show']

  className: 'icmy-container accordion-show-container'

  events:
    'click .js-parameter': 'onClickParameter'
    'transitionend': 'onTransitionEnd'
    'MSTransitionEnd': 'onTransitionEnd'
    'webkitTransitionEnd': 'onTransitionEnd'
    'oTransitionEnd': 'onTransitionEnd'

  initialize: (options) ->
    width = $('#module').width()

    if $('.page').hasClass('shift')
      width -= (Visio.Constants.FILTERS_WIDTH + 40)

    config =
      margin:
        top: 90
        bottom: 80
        left: 120
        right: 40
      width: width
      height: 450

    @figure = new Visio.Figures.Icmy config
    @filterBy = new Visio.Views.FilterBy({ figure: @figure, })

  render: (isRerender) ->

    unless isRerender
      @$el.html @template( parameter: @model, figureId: @figure.figureId() )
      @$el.find('.icmy-figure').html @figure.el
      @$el.find('.header-buttons').append @filterBy.render().el
    @


  drawFigures: ->
    parameters = new Visio.Collections[@model.name.className](@model)

    @figure.collectionFn parameters
    @figure.render()

  removeInstances: =>
    @filterBy.close()
    @figure.unsubscribe()

