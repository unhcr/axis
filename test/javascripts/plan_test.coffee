module 'Plan',
  setup: () ->
    Visio.user = new Visio.Models.User()
    Visio.manager = new Visio.Models.Manager()

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

  sinon.stub $, 'get', (url, options) ->
    if options.synced_timestamp
      return {
        new: []
        updated: []
        deleted: []
      }
    else
      {
        new: [{ id: 20 }, { id: 'abc-efg' }]
        updated: []
        deleted: []
      }



  p.fetchSynced(options).done(() ->
    strictEqual(p.models.length, 2, 'Should have 2 models')
    p.each((model) ->
      ok(model.get('id'), 'Each model should have id')
    )
    ok not $.get.calledTwice, 'Should not have called twice'
    ok $.get.calledOnce, 'Should have called once'
    return p.fetchSynced(options)
  ).done(() ->
    ok $.get.calledTwice, 'Should have called twice'
    ok $.get.args[1][1].synced_timestamp, 'Should fetch timestamp from local db'
    $.get.restore()
    start()
  )

)

asyncTest('fetchSyncedPlans for different years', () ->
  p = new Visio.Collections.Plan()

  initialCount = 0

  sinon.stub $, 'get', (url, options) ->
    if +options.year == 2012
      return {
        new: [{ id: 'ben' }]
        updated: []
        deleted: []
      }
    else
      {
        new: [{ id: 20 }, { id: 'abc-efg' }]
        updated: []
        deleted: []
      }

  options =
    year: (new Date()).getFullYear()

  p.fetchSynced(options).done(() ->
    strictEqual(p.models.length, 2, 'Should have two plans')
    # Change year
    Visio.manager.year(2012)
    options.year = Visio.manager.year()
    return p.fetchSynced(options)
  ).done(() ->
    ok not $.get.args[1][1].synced_timestamp, 'Should not have synced_timestamp for different year'
    $.get.restore()
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

asyncTest 'fetchParameter', ->

  sinon.stub $, 'get', (url, options) ->
    return {
      new: [{ id: 'hi' }, { id: 'abc-def' }]
      updated: []
      deleted: []
    }
  p = new Visio.Models.Plan({ id: '26be980c-62af-44ab-877b-de7309fa4a18', name: 'ben' })

  _.each _.values(Visio.Parameters), (hash, i) ->
    if hash.plural != Visio.Parameters.PLANS.plural
      p.fetchParameter(hash.plural).done ->
        strictEqual p.get(hash.plural).length, 2
        if i == _.values(Visio.Parameters).length - 1
          $.get.restore()
          start()

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



  result = p.strategySituationAnalysis()
  strictEqual(Visio.Algorithms.ALGO_RESULTS.success, result.category)

  Visio.manager.get('strategies').reset([{
      id: 1
      plan_ids: { 1: true }
      goal_ids: { 1: true }
      ppg_ids: { 1: true }
      output_ids: { 1: true }
      problem_objective_ids: { 1: true }
      indicator_ids: { 1: true }
    },
    {
      id: 2,
      plan_ids: {}
      goal_ids: {}
      ppg_ids: {}
      output_ids: {}
      problem_objective_ids: {}
      indicator_ids: {}
    }])

  Visio.manager.get('selected_strategies')['1'] = true
  Visio.manager.get('selected_strategies')['2'] = true
  result = p.strategySituationAnalysis()
  strictEqual(Visio.Algorithms.ALGO_RESULTS.fail, result.category)

  delete Visio.manager.get('selected_strategies')['2']

  result = p.strategySituationAnalysis()
  strictEqual(Visio.Algorithms.ALGO_RESULTS.fail, result.category)

  Visio.manager.get('strategies').reset([{
      id: 1
      plan_ids: { 'abcd': true }
      goal_ids: { 1: true }
      ppg_ids: { 1: true }
      output_ids: { 1: true }
      problem_objective_ids: { 1: true }
      indicator_ids: { 1: true }
    },
    {
      id: 2,
      plan_ids: {}
      goal_ids: {}
      ppg_ids: {}
      output_ids: {}
      problem_objective_ids: {}
      indicator_ids: {}
    }])

  result = p.strategySituationAnalysis()
  strictEqual(Visio.Algorithms.ALGO_RESULTS.ok, result.category)

