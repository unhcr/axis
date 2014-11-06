class Visio.Views.MapView extends Visio.Views.Module

  @include Visio.Mixins.Narratify

  template: HAML['modules/map']

  className: 'module'

  id: 'map'

  initialize: (options) ->

    config =
      width: @figureWidth true
      height: 800
      model: new Visio.Models.Map()

    @figure = new Visio.Figures.Map config

    @narratify @figure

  render: (isRerender) ->

    if !isRerender
      @$el.html @template()
      @$el.find('figure').html @figure.el
      @$el.find('.header-buttons').append (new Visio.Views.FilterBy({ figure: @figure })).render().el

    @drawFigures()
    @

  drawFigures: =>
    @figure.collectionFn Visio.manager.selected 'operations'
    @figure.render()
