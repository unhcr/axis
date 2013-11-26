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

  getMap: () ->
    db = @get('db')
    assert(@get('mapMD5'))

    $.when(db.get(Visio.Stores.MAP, @get('mapMD5'))).then((record) =>
      if !record
        return $.get('/map')
      else
        return record
    ).done((record) =>
      db.put(Visio.Stores.MAP, record, @get('mapMD5'))
    ).done(() =>
      db.get(Visio.Stores.MAP, @get('mapMD5'))
    )
