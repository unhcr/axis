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
  id = 'ben'

  p.setSynced(plans, id).done(() ->
    return p.getSynced()
  ).done((records) ->
    strictEqual(2, records.length, 'length of plans')
    plans.new = []
    plans.updated = [{ id: 'bob', name: 'matt' }]
    plans.deleted = [{ id: 'wendy', name: 'sue' }]
    return Visio.manager.getSyncDate(id)
  ).done((record) ->
    ok(record.synced_timestamp, 'Should sync the date')
    timestamp = record.synced_timestamp
    return p.setSynced(plans)
  ).done(() ->
    return Visio.manager.getSyncDate(id)
  ).done((record) ->
    strictEqual(timestamp, record.synced_timestamp, 'Should not have updated sync date')
    return p.getSynced()
  ).done((records) ->
    strictEqual('matt', records[0].name, 'Update 1 plan')
    strictEqual(1, records.length, 'Deleted 1 plan')
    return Visio.manager.getSyncDate(id)
  ).done((record) ->
    ok(record, 'Should have the record')
    ok(record.synced_timestamp, 'Should set synced timestamp')
    start()
  )

)

asyncTest('fetchSyncedPlans', () ->

  p = new Visio.Collections.Plan()

  options =
    options:
      include:
        counts: true


  p.fetchSynced(options).done(() ->
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

asyncTest('fetchSyncedPlans for different years', () ->
  p = new Visio.Collections.Plan()

  initialCount = 0

  options =
    year: (new Date()).getFullYear()

  p.fetchSynced(options).done(() ->
    ok(p.models.length > 0, 'Should have greater than 0 plans')
    initialCount = p.models.length
    # Change year
    Visio.manager.year(2012)
    options.year = Visio.manager.year()
    return p.fetchSynced(options)
  ).done(() ->
    ok(p.models.length > initialCount)
    start()
  )

)

test('find plan', () ->
  Visio.manager.get('plans').reset([{ id: 'bien', year: 2013, country: { iso3: 'BEN' } },
                              { id: 'dirk', year: 2013, country: { iso3: 'UGA' } }])

  plan = Visio.manager.plan('bien')
  ok(plan, 'Must have plan')
  strictEqual(plan.id, 'bien')
  Visio.manager.year(2013)

  plan = Visio.manager.plan('UGA')
  ok(plan, 'Must have plan')
  strictEqual(plan.id, 'dirk')

  Visio.manager.year(2012)
  plan = Visio.manager.plan('UGA')
  ok(!plan, 'Must not have plan')
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

test 'strategy situation analysis', () ->
  p = new Visio.Models.Plan({ id: 'abcd', name: 'ben', situation_analysis:
    {
      category: Visio.Algorithms.ALGO_RESULTS.success
      result: 1
    }
  })
  Visio.manager.get('indicator_data').reset([
    {
      id: 1
      yer: 20
      myr: 8
      threshold_green: 10
      threshold_red: 5
      plan_id: 'abcd'
      goal_id: 1
      output_id: 1
      ppg_id: 1
      problem_objective_id: 1
      indicator_id: 1
      is_performance: false
    },
    {
      id: 2
      yer: 30
      myr: 21
      threshold_green: 40
      threshold_red: 20
      plan_id: 2
      goal_id: 2
      output_id: 2
      ppg_id: 2
      problem_objective_id: 2
      indicator_id: 2
      is_performance: false
    }])



  result = p.strategy_situation_analysis()
  strictEqual(Visio.Algorithms.ALGO_RESULTS.success, result.category)

  Visio.manager.get('strategies').reset([{
      id: 1
      plans_ids: { 1: true }
      goals_ids: { 1: true }
      ppgs_ids: { 1: true }
      outputs_ids: { 1: true }
      problem_objectives_ids: { 1: true }
      indicators_ids: { 1: true }
    },
    {
      id: 2,
      plans_ids: {}
      goals_ids: {}
      ppgs_ids: {}
      outputs_ids: {}
      problem_objectives_ids: {}
      indicators_ids: {}
    }])

  $('body').append('<div class="priority-country-filter"></div>')
  $('.priority-country-filter').append('<div class="visio-check"><input type="checkbox" checked="checked" value="1" /><input checked="checked" value="2" type="checkbox"/></div>')

  result = p.strategy_situation_analysis()
  strictEqual(Visio.Algorithms.ALGO_RESULTS.fail, result.category)

  $('.visio-check').html('<input type="checkbox" checked="checked" value="1" /><input value="2" type="checkbox"/>')

  result = p.strategy_situation_analysis()
  strictEqual(Visio.Algorithms.ALGO_RESULTS.fail, result.category)

  Visio.manager.get('strategies').reset([{
      id: 1
      plans_ids: { 'abcd': true }
      goals_ids: { 1: true }
      ppgs_ids: { 1: true }
      outputs_ids: { 1: true }
      problem_objectives_ids: { 1: true }
      indicators_ids: { 1: true }
    },
    {
      id: 2,
      plans_ids: {}
      goals_ids: {}
      ppgs_ids: {}
      outputs_ids: {}
      problem_objectives_ids: {}
      indicators_ids: {}
    }])

  result = p.strategy_situation_analysis()
  strictEqual(Visio.Algorithms.ALGO_RESULTS.ok, result.category)

