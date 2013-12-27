module 'Manager',

  setup: () ->
    stop()
    Visio.user = new Visio.Models.User()
    Visio.manager = new Visio.Models.Manager()
    start()

  teardown: () ->
    Visio.manager.get('db').clear()

asyncTest('getLastSync', () ->
  id = 'ben'
  Visio.manager.setSyncDate(id).done((key) ->
    return Visio.manager.getSyncDate(id)
  ).done((record) ->
    ok(record.synced_timestamp, 'Should have a sync date')
    start()
  )

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

asyncTest('getMap', () ->
  Visio.manager.set 'mapMD5', 'abc123'

  sinon.stub $, 'get', (url, options) ->
    if url == '/map'
      return { object: 'my map object' }

  Visio.manager.getMap().done((map) ->
    # Should retreive via ajax
    ok $.get.calledOnce, 'Should have been called once at this point'
    ok(map, 'Should have map')
  ).done(() ->
    Visio.manager.getMap()
  ).done((map) ->
    # Should retreive local
    ok $.get.calledOnce, 'Should not have been called a second time'
    ok(map, 'Should have map')
    $.get.restore()
    start()
  )
)

test('strategies', () ->
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
  strictEqual(strategies.length, 3)
  ok(strategies instanceof Visio.Collections.Strategy, "Must be instance of Strategy. Was: #{strategies.contructor}")
)

test 'selected', () ->
  selected = Visio.manager.get('selected')

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
    selected = Visio.manager.selected(hash.plural)

    ok(selected instanceof Visio.manager.get(hash.plural).constructor)
    strictEqual(selected.length, 1)
    ok(selected.get(1))

test 'plan', () ->
  Visio.manager.get('plans').reset([
    {
      id: 'abc'
      country: { iso3: 'ben' }
      year: Visio.manager.year()
    }
    {
      id: 'ben'
      country: { iso3: 'aaa' }
      year: Visio.manager.year()
    }
  ])

  p = Visio.manager.plan('ben')
  strictEqual p.id, 'ben'

  p = Visio.manager.plan('aaa')
  strictEqual p.id, 'ben'

test 'resetSelectedDefaults', () ->

  strategy = { id: 17 }

  _.each _.values(Visio.Parameters), (hash) ->
    strategy["#{hash.singular}_ids"] = {}
    strategy["#{hash.singular}_ids"]['1'] = true
    strategy["#{hash.singular}_ids"]['2'] = true

  Visio.manager.get('strategies').reset([strategy])
  Visio.manager.set('strategy_id', Visio.manager.get('strategies').at(0).id)

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
    if hash.plural != Visio.Parameters.PLANS.plural
      strictEqual(_.keys(Visio.manager.get('selected')[hash.plural]).length, 2)
    else
      strictEqual(_.keys(Visio.manager.get('selected')[hash.plural]).length, 1)

test 'validation', ->

  throws(
    () ->
      Visio.manager.set(Visio.Parameters.PLANS.plural, new Visio.Collections.Ppg())
    , /mismatched/, 'Raise a mismatch error')

  throws(
    () ->
      Visio.manager.set(Visio.Parameters.PLANS.plural, undefined)
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
