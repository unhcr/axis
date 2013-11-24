class Visio.Routers.IndexRouter extends Backbone.Router

  initialize: (options) ->

    @map = Visio.Graphs.map(
      margin:
        top: 0
        left: 0
        right: 0
        bottom: 0
      selection: d3.select '#map'
      width: $(window).width()
      height: 500)


    Visio.manager.getMap(
      success: (data) =>
        @map.mapJSON(data.map)
        @map()
      fail: (err) =>
        console.log err)

  routes: () ->
    '*default': 'index'

  index: () ->
