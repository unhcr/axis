class Visio.Models.Manager extends Backbone.Model

  initialize: () ->
    @set('db', new ydn.db.Storage(Visio.Constants.DB_NAME))

  defaults:
    'plans': new Visio.Collections.Plan()
    'date': new Date()
    'db': null
    'mapMD5': null
    'syncDateId': 'syncDateId'

  setSyncedPlans: (plans) ->
    db = @get('db')

    req = db.put({
      name: Visio.Stores.PLANS
      keyPath: 'id' }, plans.new.concat(plans.updated))

    if plans.deleted.length > 0
      req.done((ids) ->
        # Remove deleted plans
        req = null
        _.each(plans.deleted, (plan) ->
          req = db.remove(Visio.Stores.PLANS, plan.id)
        )
        return req
      )
    else
      return req

  getSyncedPlans: () ->
    db = @get('db')
    db.values(Visio.Stores.PLANS)

  # Goes to server to fetch plans
  fetchSyncedPlans: (options) ->
    db = @get('db')
    plans = @get('plans')


    @getSyncDate().then((record) ->
      return plans.fetch(synced_date: record.synced_date)
    ).then((response) ->
      return @setSyncedPlans(response.plans)
    ).then(() ->
      return db.values(Visio.Stores.PLANS)
    ).done((records) ->
      options.success(records) if options.success
    )

  getSyncDate: () ->
    db = @get('db')
    db.get(Visio.Stores.SYNC, @get('syncDateId'))

  setSyncDate: (options) ->
    d = new Date()
    db = @get('db')

    req = db.put(Visio.Stores.SYNC, { synced_date: +d }, @get('syncDateId'))
    req

  getMap: (options) ->
    db = @get('db')
    req = db.get(Visio.Stores.MAP, @get('mapMD5'))

    req.done (record) ->
      if !record
        $.get('/map', (map) =>
          db.put(Visio.Stores.MAP, { map: map }, options.mapMD5)
        )
        options.success(record) if options.success
      else
        options.success(record) if options.success

    req.fail (err) ->
      options.fail(err) if options.fail

    req
