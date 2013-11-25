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

  p.setSynced(plans).done(() ->
    return p.getSynced()
  ).done((records) ->
    strictEqual(2, records.length, 'length of plans')
    plans.new = []
    plans.updated = [{ id: 'bob', name: 'matt' }]
    plans.deleted = [{ id: 'wendy', name: 'sue' }]

    return p.setSynced(plans)
  ).done(() ->
    return p.getSynced()
  ).done((records) ->
    strictEqual('matt', records[0].name, 'Update 1 plan')
    strictEqual(1, records.length, 'Deleted 1 plan')
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
    start()
  )
)
