class Visio.Views.IcmyView extends Visio.Views.AccordionIndexView

  showView: (options) -> new Visio.Views.IcmyShowView(options)

  className: 'module'

  id: 'icmy'

  events:
    'click .js-parameter': 'onClickParameter'
    'transitionend': 'onTransitionEnd'
    'MSTransitionEnd': 'onTransitionEnd'
    'webkitTransitionEnd': 'onTransitionEnd'

  initialize: (options) ->
    super options
    width = $('#module').width()

    unless $('.page').hasClass('shift')
      width -= (Visio.Constants.LEGEND_WIDTH + 40)


    config =
      width: width
      height: 420
      summary: true
      margin:
        top: 90
        bottom: 90
        left: 180
        right: 80

    @figure = new Visio.Figures.Icmy config

  render: (isRerender) ->
    super isRerender

    unless isRerender
      @$el.find('.summary-figure').html @figure.el
      @$el.find('.summary-figure .header-buttons').append (new Visio.Views.FilterBy({ figure: @figure, })).render().el


    @drawFigures()
    @

  drawFigures: ->
    parameters = Visio.manager.selected(Visio.manager.get('aggregation_type'))

    @figure.collectionFn parameters
    @figure.render()

  sort: (parameterA, parameterB) ->
    0
