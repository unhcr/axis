class Visio.Models.Manager extends Backbone.Model

  initialize: () ->
    @set('db', new ydn.db.Storage(Visio.Constants.DB_NAME))

  defaults:
    'plans': new Visio.Collections.Plan()
    'date': new Date()
    'db': null
    'mapMD5': null
    'syncTimestampId': 'syncTimestampId'

  getSyncDate: () ->
    db = @get('db')
    db.get(Visio.Stores.SYNC, @get('syncTimestampId'))

  setSyncDate: (options) ->
    d = new Date()
    db = @get('db')

    db.put(Visio.Stores.SYNC, { synced_timestamp: +d }, @get('syncTimestampId'))

  getMap: (options) ->
    db = @get('db')
    req = db.get(Visio.Stores.MAP, @get('mapMD5'))

    req.done (record) =>
      if !record
        $.get('/map', (map) =>
          db.put(Visio.Stores.MAP, { map: map }, @get('mapMD5'))
        )
        options.success(record) if options.success
      else
        options.success(record) if options.success

    req.fail (err) ->
      options.fail(err) if options.fail

    req
