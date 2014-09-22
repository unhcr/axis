class Visio.Views.MapView extends Backbone.View

  @include Visio.Mixins.Narratify

  template: HAML['modules/map']

  className: 'module'

  id: 'map'

  initialize: (options) ->
    width = $('#module').width()

    #unless $('.page').hasClass('shift')
    #  width -= (Visio.Constants.LEGEND_WIDTH + 40)

    config =
      width: width
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
