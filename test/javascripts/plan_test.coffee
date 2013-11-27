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
      ok(_.isNumber(model.get('indicators_count')), 'Each model should have i count')
      ok(_.isNumber(model.get('ppgs_count')), 'Each model should have ppg count')
      ok(_.isNumber(model.get('goals_count')), 'Each model should have goal count')
      ok(_.isNumber(model.get('outputs_count')), 'Each model should have o count')
      ok(_.isNumber(model.get('problem_objectives_count')), 'Each model should have po count')
    )
    return p.fetchSynced()
  ).done(() ->
    #TODO Need to check to ensure that it hasn't recomputed all plans
    start()
  )
)

asyncTest('fetchIndicators', () ->

  p = new Visio.Models.Plan({ id: '26be980c-62af-44ab-877b-de7309fa4a18', name: 'ben' })

  strictEqual(p.id, '26be980c-62af-44ab-877b-de7309fa4a18')
  strictEqual(p.get('name'), 'ben')

  p.fetchIndicators().done((id) ->
    strictEqual(p.id, id)
    p.getSynced().done((record) ->
      strictEqual(p.get('indicators').length, record.indicators.length)
      start()
    )
  )

)

asyncTest('fetchPpgs', () ->

  p = new Visio.Models.Plan({ id: '26be980c-62af-44ab-877b-de7309fa4a18', name: 'ben' })

  strictEqual(p.id, '26be980c-62af-44ab-877b-de7309fa4a18')
  strictEqual(p.get('name'), 'ben')

  p.fetchPpgs().done((id) ->
    strictEqual(p.id, id)
    p.getSynced().done((record) ->
      strictEqual(p.get('ppgs').length, record.ppgs.length)
      start()
    )
  )

)

asyncTest('fetchOutputs', () ->

  p = new Visio.Models.Plan({ id: '26be980c-62af-44ab-877b-de7309fa4a18', name: 'ben' })

  strictEqual(p.id, '26be980c-62af-44ab-877b-de7309fa4a18')
  strictEqual(p.get('name'), 'ben')

  p.fetchOutputs().done((id) ->
    strictEqual(p.id, id)
    p.getSynced().done((record) ->
      strictEqual(p.get('outputs').length, record.outputs.length)
      start()
    )
  )

)
asyncTest('fetchProblemObjectives', () ->

  p = new Visio.Models.Plan({ id: '26be980c-62af-44ab-877b-de7309fa4a18', name: 'ben' })

  strictEqual(p.id, '26be980c-62af-44ab-877b-de7309fa4a18')
  strictEqual(p.get('name'), 'ben')

  p.fetchProblemObjectives().done((id) ->
    strictEqual(p.id, id)
    p.getSynced().done((record) ->
      strictEqual(p.get('problem_objectives').length, record.problem_objectives.length)
      start()
    )
  )

)
asyncTest('fetchGoals', () ->

  p = new Visio.Models.Plan({ id: '26be980c-62af-44ab-877b-de7309fa4a18', name: 'ben' })

  strictEqual(p.id, '26be980c-62af-44ab-877b-de7309fa4a18')
  strictEqual(p.get('name'), 'ben')

  p.fetchGoals().done((id) ->
    strictEqual(p.id, id)
    p.getSynced().done((record) ->
      strictEqual(p.get('goals').length, record.goals.length)
      start()
    )
  )

)

test('find plan', () ->
  Visio.manager.get('plans').reset([{ id: 'bien', year: 2013, country: { iso3: 'BEN' } },
                              { id: 'dirk', year: 2013, country: { iso3: 'UGA' } }])

  plan = Visio.manager.plan('bien')
  ok(plan, 'Must have plan')
  strictEqual(plan.id, 'bien')
  Visio.manager.setYear(2013)

  plan = Visio.manager.plan('UGA')
  ok(plan, 'Must have plan')
  strictEqual(plan.id, 'dirk')

  Visio.manager.setYear(2012)
  plan = Visio.manager.plan('UGA')
  ok(!plan, 'Must not have plan')
)
