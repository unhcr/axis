class Visio.Routers.IndexRouter extends Backbone.Router

  initialize: (options) ->

    @map = Visio.Graphs.map(
      margin:
        top: 0
        left: 0
        right: 0
        bottom: 0
      selection: d3.select '#map'
      mapJSON: options.map
      width: $(window).width()
      height: 500)

    @map()

  routes: () ->
    '*default': 'index'

  index: () ->
