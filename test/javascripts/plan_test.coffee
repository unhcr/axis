module 'Plan',
  setup: () ->
    stop()
    Visio.manager = new Visio.Models.Manager()
    start()

  teardown: () ->
    Visio.manager.get('db').clear()

asyncTest('setSyncedPlans', () ->
  p = new Visio.Collections.Plan()
  plans = {
    new: [{ id: 'bob', name: 'george' }, { id: 'wendy', name: 'sue' }]
    deleted: []
    updated: []
  }

  timestamp = null

  p.setSynced(plans, true).done(() ->
    return p.getSynced()
  ).done((records) ->
    strictEqual(2, records.length, 'length of plans')
    plans.new = []
    plans.updated = [{ id: 'bob', name: 'matt' }]
    plans.deleted = [{ id: 'wendy', name: 'sue' }]
    return Visio.manager.getSyncDate()
  ).done((record) ->
    ok(record.synced_timestamp, 'Should sync the date')
    timestamp = record.synced_timestamp
    return p.setSynced(plans, false)
  ).done(() ->
    return Visio.manager.getSyncDate()
  ).done((record) ->
    strictEqual(timestamp, record.synced_timestamp, 'Should not have updated sync date')
    return p.getSynced()
  ).done((records) ->
    strictEqual('matt', records[0].name, 'Update 1 plan')
    strictEqual(1, records.length, 'Deleted 1 plan')
    return Visio.manager.getSyncDate()
  ).done((record) ->
    ok(record, 'Should have the record')
    ok(record.synced_timestamp, 'Should set synced timestamp')
    start()
  )

)

asyncTest('fetchSyncedPlans', () ->

  p = new Visio.Collections.Plan()

  p.fetchSynced().done(() ->
    ok(p.models.length > 0, 'Should have greater than 0 plans')
    p.each((model) ->
      ok(model.get('id'), 'Each model should have id')
      ok(_.isNumber(model.get('indicator_count')), 'Each model should have i count')
      ok(_.isNumber(model.get('ppg_count')), 'Each model should have ppg count')
      ok(_.isNumber(model.get('goal_count')), 'Each model should have goal count')
      ok(_.isNumber(model.get('output_count')), 'Each model should have o count')
      ok(_.isNumber(model.get('problem_objective_count')), 'Each model should have po count')
    )
    return p.fetchSynced()
  ).done(() ->
    #TODO Need to check to ensure that it hasn't recomputed all plans
    start()
  )
)