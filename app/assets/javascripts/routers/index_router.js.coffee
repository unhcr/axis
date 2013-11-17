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

    req = Visio.db.get(Visio.Constants.MAP_STORE, options.mapMD5)

    req.done (record) =>
      if !record
        $.get('/map', (map) =>
          console.log 'Got map'
          Visio.db.put(Visio.Constants.MAP_STORE, { map: map }, options.mapMD5)
          @map.mapJSON(map)
          @map()
        )
      else
        console.log 'Stored map'
        @map.mapJSON(record.map)
        @map()

    req.fail (e) ->
      console.log e


  routes: () ->
    '*default': 'index'

  index: () ->
