class Visio.Models.Manager extends Backbone.Model

  initialize: () ->
    @set('db', new ydn.db.Storage(Visio.Constants.DB_NAME))

  defaults:
    'plans': new Visio.Collections.Plan()
    'date': new Date()
    'db': null
    'mapMD5': null
    'syncTimestampId': 'syncTimestampId'

  year: () ->
    @get('date').getFullYear()

  setYear: (year) ->
    @set('date', new Date(year, 1))

  plan: (idOrISO) ->
    if idOrISO.length == 3
      plan = @get('plans').find((p) =>
        p.get('country').iso3 == idOrISO && p.get('year') == @year()
      )
      return plan
    else
      return @get('plans').get(idOrISO)

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
