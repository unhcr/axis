class Visio.Views.IcmyShowView extends Visio.Views.AccordionShowView

  @include Visio.Mixins.Narratify

  template: HAML['modules/icmy_show']

  className: 'icmy-container accordion-show-container'

  events:
    'click .js-parameter': 'onClickParameter'
    'transitionend': 'onParameterTransitionEnd'
    'MSTransitionEnd': 'onParameterTransitionEnd'
    'webkitTransitionEnd': 'onParameterTransitionEnd'
    'oTransitionEnd': 'onParameterTransitionEnd'

  initialize: (options) ->
    width = $('#module').width()

    config =
      margin:
        top: 90
        bottom: 80
        left: 180
        right: 40
      width: width
      height: 450

    @figure = new Visio.Figures.Icmy config
    @filterBy = new Visio.Views.FilterBy({ figure: @figure, })
    @narratify @figure

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

