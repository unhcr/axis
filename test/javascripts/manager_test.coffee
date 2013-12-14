module 'Manager',

  setup: () ->
    stop()
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
  $.when($.get('/maphash')).then((response) ->
    Visio.manager.set('mapMD5', response.mapMD5)
  ).done(() ->
    return Visio.manager.getMap().done((map) ->
      # Should retreive via ajax
      ok(map, 'Should have map')
      strictEqual topojson.feature(map, map.objects.world_50m).features.length, 304
    ).done(() ->
      Visio.manager.getMap()
    ).done((map) ->
      # Should retreive local
      ok(map, 'Should have map')
      strictEqual topojson.feature(map, map.objects.world_50m).features.length, 304
      start()
    )
  )
)

test('strategies', () ->
  Visio.manager.get('strategies').reset([
    {
      id: 'ben'
    },
    {
      id: 'lisa'
    },
    {
      id: 'jeff'
    }
  ])

  strategies = Visio.manager.strategies(['ben', 'lisa'])
  strictEqual(strategies.length, 2)
  ok(strategies instanceof Visio.Collections.Strategy)

  strategies = Visio.manager.strategies(['ben'])
  strictEqual(strategies.length, 1)
  strictEqual(strategies.at(0).id, 'ben')
  ok(strategies instanceof Visio.Collections.Strategy)

  strategies = Visio.manager.strategies([])
  strictEqual(strategies.length, 3)
  ok(strategies instanceof Visio.Collections.Strategy)
)

test 'selected', () ->
  selected = Visio.manager.get('selected')

  _.each Visio.Types, (type) ->
    selected[type] = {}
    selected[type]['1'] = true

  Visio.manager.set 'selected', selected

  _.each Visio.Types, (type) ->
    Visio.manager.get(type).reset([
      {
        id: 1
      },
      {
        id: 2
      }
    ])
    selected = Visio.manager.selected(type)

    ok(selected instanceof Visio.manager.get(type).constructor)
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

test 'resetSelected', () ->

  strategy = { id: 17 }

  _.each Visio.Types, (type) ->
    strategy["#{type}_ids"] = {}
    strategy["#{type}_ids"]['1'] = true
    strategy["#{type}_ids"]['2'] = true

  Visio.manager.get('strategies').reset([strategy])
  Visio.manager.set('strategy_id', Visio.manager.get('strategies').at(0).id)

  _.each Visio.Types, (type) ->
    Visio.manager.get(type).reset([
      {
        id: 1
        year: Visio.manager.year()
      },
      {
        id: 2
      }
    ])

  Visio.manager.resetSelected()

  _.each Visio.Types, (type) ->
    if type != Visio.Parameters.PLANS
      strictEqual(_.keys(Visio.manager.get('selected')[type]).length, 2)
    else
      strictEqual(_.keys(Visio.manager.get('selected')[type]).length, 1)
