class Visio.Models.Manager extends Backbone.Model

  initialize: () ->
    @set('db', new ydn.db.Storage(Visio.Constants.DB_NAME))

  defaults:
    'operations': []
    'date': new Date()
    'db': null
    'mapMD5': null

  getLastSync: () ->

  getMap: (options) ->
    db = @get('db')
    req = db.get(Visio.Constants.MAP_STORE, @get('mapMD5'))

    req.done (record) =>
      if !record
        $.get('/map', (map) =>
          db.put(Visio.Constants.MAP_STORE, { map: map }, options.mapMD5)
        )
        options.success(record) if options.success
      else
        options.success(record) if options.success

    req.fail (e) ->
      options.fail(e) if options.fail
