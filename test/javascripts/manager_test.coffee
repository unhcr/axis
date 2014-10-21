module 'Manager',

  setup: () ->
    Visio.user = new Visio.Models.User()
    Visio.manager = new Visio.Models.Manager()

  teardown: () ->
    delete Visio.manager

asyncTest 'getLastSync', () ->
  id = 'ben'
  Visio.manager.setSyncDate(id).done((key) ->
    return Visio.manager.getSyncDate(id)
  ).done((record) ->
    ok(record.synced_timestamp, 'Should have a sync date')
    start()
  )

asyncTest('setLastSync', () ->
  s = new Date()

  id = 'lisa'
  Visio.manager.setSyncDate(id).done(() ->
    return Visio.manager.getSyncDate(id)
    ).then((record) ->
      ok(+record.synced_timestamp >= +s, 'Should always be less than sync date')
      start()
    )
)

asyncTest('setSyncDate with different ids', () ->
  id = 10
  id2 = 15
  Visio.manager.setSyncDate(id).done(() ->
    return Visio.manager.getSyncDate(id2)
  ).then((record) ->
    ok(!record, 'Should not have record for different ids')
    start()
  )

)

test 'strategies', ->
  Visio.manager.get('strategies').reset([
    {
      id: 1
    },
    {
      id: 2
    },
    {
      id: 3
    }
  ])
  ok not Visio.manager.strategy()
  Visio.manager.set('strategy_id', 1)

  ok Visio.manager.strategy()
  strictEqual Visio.manager.strategy().id, 1

  strategies = Visio.manager.strategies([1, 2])
  strictEqual(strategies.length, 2)
  ok(strategies instanceof Visio.Collections.Strategy)

  strategies = Visio.manager.strategies([1])
  strictEqual(strategies.length, 1)
  strictEqual(strategies.at(0).id, 1)
  ok(strategies instanceof Visio.Collections.Strategy)

  strategies = Visio.manager.strategies([])
  strictEqual(strategies.length, 0)
  ok(strategies instanceof Visio.Collections.Strategy, "Must be instance of Strategy. Was: #{strategies.contructor}")

test 'selected', () ->
  selected = Visio.manager.get('selected')
  strategy = new Visio.Models.Strategy
  Visio.manager.get('strategies').reset([{ id: 3, strategy_objective_ids: {1:true} }])
  Visio.manager.set('strategy_id', 3)

  _.each _.values(Visio.Parameters), (hash) ->
    selected[hash.plural] = {}
    selected[hash.plural]['1'] = true

  Visio.manager.set 'selected', selected

  _.each _.values(Visio.Parameters), (hash) ->
    Visio.manager.get(hash.plural).reset([
      {
        id: 1
      },
      {
        id: 2
      }
    ])

    if hash == Visio.Parameters.STRATEGY_OBJECTIVES
      Visio.manager.get(hash.plural).get(1).set('strategy_id', 3)

    selected = Visio.manager.selected(hash.plural)

    ok(selected instanceof Visio.manager.get(hash.plural).constructor)
    strictEqual(selected.length, 1)
    ok(selected.get(1))

test 'toStrategyParams', ->
  Visio.manager.set 'selected', {}
  r = Visio.manager.toStrategyParams()
  ok _.isEmpty r.operations
  ok _.isEmpty r.ppgs
  ok _.isEmpty r.strategy_objectives

  selected =
    operations:
      'A': true
      'B': true
      'C': true
    goals:
      'D': true
    strategy_objectives:
      'E': true

  Visio.manager.set 'selected', selected
  Visio.manager.set 'strategy_objectives',
    new Visio.Collections.StrategyObjective({ id: 'E', goals: { id: 'D' } })

  Visio.manager.includeExternalStrategyData false

  r = Visio.manager.toStrategyParams()

  strictEqual r.operations.length, 3
  strictEqual r.strategy_objectives.length, 1
  strictEqual r.strategy_objectives[0].goals.length, 1
  ok !r.strategy_objectives[0].id
  ok _.indexOf(_.map(r.operations, (o) -> o.id), 'A') != -1

test 'toStrategyParams include external', ->

  selected =
    operations:
      'A': true
      'B': true
      'C': true
    goals:
      'D': true


  Visio.manager.set 'selected', selected
  Visio.manager.set 'goals', new Visio.Collections.Goal([{ id: 'D' }, { id: 'F' }])
  Visio.manager.set 'operations', new Visio.Collections.Operation([{ id: 'A' }, { id: 'C' }, { id: 'B' }])
  Visio.manager.set 'problem_objectives', new Visio.Collections.ProblemObjective()
  Visio.manager.set 'outputs', new Visio.Collections.Output()
  Visio.manager.set 'indicators', new Visio.Collections.Indicator()

  Visio.manager.includeExternalStrategyData true

  r = Visio.manager.toStrategyParams()

  strictEqual r.operations.length, 3
  strictEqual r.strategy_objectives.length, 1
  strictEqual r.strategy_objectives[0].goals[0].id, 'D'

test 'formattedIds', ->

  Visio.manager.set 'selected', { operations: { 'BEN': true }, ppgs: { 'LISA': true } }

  formatted = Visio.manager.formattedIds()

  ok _.isArray formatted.operation_ids
  ok _.isArray formatted.ppg_ids

  strictEqual formatted.operation_ids.length, 1
  strictEqual formatted.ppg_ids.length, 1

test 'resetSelectedDefaults', () ->

  strategy = { id: 17 }

  _.each _.values(Visio.Parameters), (hash) ->
    strategy["#{hash.singular}_ids"] = {}
    strategy["#{hash.singular}_ids"]['1'] = true
    strategy["#{hash.singular}_ids"]['2'] = true

  Visio.manager.get('strategies').reset([strategy])
  Visio.manager.set('strategy_id', Visio.manager.get('strategies').at(0).id)
  Visio.manager.set 'dashboard', Visio.manager.strategy()

  _.each _.values(Visio.Parameters), (hash) ->
    Visio.manager.get(hash.plural).reset([
      {
        id: 1
        year: Visio.manager.year()
      },
      {
        id: 2
      }
    ])

  Visio.manager.resetSelectedDefaults()

  _.each _.values(Visio.Parameters), (hash) ->
    strictEqual Visio.manager.selected(hash.plural).length, 2

test 'resetSelectedDefaults - operation dashboard', ->
  operation = new Visio.Models.Operation
    id: 'lawd'
    ppg_ids:
      abc: true
      def: true

  Visio.manager.set 'dashboard', operation
  Visio.manager.get('strategy_objectives').reset [{ id: '123' }]
  Visio.manager.get('ppgs').reset [{ id: 'abc' }, { id: 'def' }]
  Visio.manager.get('operations').reset [operation]
  Visio.manager.includeExternalStrategyData true

  Visio.manager.resetSelectedDefaults()

  strictEqual Visio.manager.selected('ppgs').length, 2

  strictEqual Visio.manager.selected('strategy_objectives').length, 2
  ok Visio.manager.get('strategy_objectives').get(Visio.Constants.ANY_STRATEGY_OBJECTIVE)
  ok Visio.manager.get('strategy_objectives').get('123')

  strictEqual Visio.manager.selected('operations').length, 1

test 'includeExternalStrategyData', ->

  Visio.manager.includeExternalStrategyData true

  ok Visio.manager.get('strategy_objectives').get Visio.Constants.ANY_STRATEGY_OBJECTIVE
  ok Visio.manager.includeExternalStrategyData()

  Visio.manager.includeExternalStrategyData false
  ok !Visio.manager.get('strategy_objectives').get Visio.Constants.ANY_STRATEGY_OBJECTIVE
  ok !Visio.manager.includeExternalStrategyData()

test 'configuration', ->

  Visio.configuration =
    default_date: 2013
    default_use_local_db: false
    startyear: 2013
    endyear: 2015

  m = new Visio.Models.Manager()


  ok !m.get('default_use_local_db')
  strictEqual m.get('yearList')[0], 2013
  strictEqual m.get('yearList')[1], 2014
  strictEqual m.get('yearList')[2], 2015

  strictEqual m.get('date').getFullYear(), 2013

  Visio.configuration = {}

test 'dashboardName', ->
  Visio.manager.set 'dashboard', new Visio.Models.Operation({ name: 'rudolph' })
  strictEqual Visio.manager.dashboardName(), 'rudolph'

  Visio.manager.set 'indicator', new Visio.Models.Indicator({ name: 'ben' })
  strictEqual Visio.manager.dashboardName(), 'ben'

#test 'call ready with no local storage', ->
#
#  cb = sinon.spy()
#
#  Visio.configuration =
#    default_use_local_db: false
#
#  m = new Visio.Models.Manager(ready: cb)
#
#  ok cb.calledOnce, 'callback should be called'
#
#  Visio.configuration = {}
#
test 'validation', ->

  throws(
    () ->
      Visio.manager.set(Visio.Parameters.OPERATIONS.plural, new Visio.Collections.Ppg())
    , /mismatched/, 'Raise a mismatch error')

  throws(
    () ->
      Visio.manager.set(Visio.Parameters.OPERATIONS.plural, undefined)
    , /mismatched/, 'Raise a mismatch error')

  throws(
    () ->
      Visio.manager.year(1990)
    , /year/, 'Raise a wrong year error')

  throws(
    () ->
      Visio.manager.set('aggregation_type', 'abcdef')
    , /aggregation_type/, 'Raise a wrong aggregation_type error')

  throws(
    () ->
      Visio.manager.set('achievement_type', 'abcdef')
    , /achievement_type/, 'Raise a wrong achievement_type error')

test 'select', ->

  ids = [1, 2, 'abc']
  for key, hash of Visio.Parameters
    Visio.manager.select hash.plural, ids

    _.each ids, (id) ->
      ok Visio.manager.get('selected')[hash.plural][id], "#{hash.plural} id: #{id} should be selected"

  id = 'wham'

  for key, hash of Visio.Parameters
    Visio.manager.select hash.plural, id

    ok Visio.manager.get('selected')[hash.plural][id], "#{hash.plural} id: #{id} should be selected"
