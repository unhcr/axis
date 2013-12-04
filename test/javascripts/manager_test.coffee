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
      strictEqual map.features.length, 306
    ).done(() ->
      Visio.manager.getMap()
    ).done((map) ->
      # Should retreive local
      ok(map, 'Should have map')
      strictEqual map.features.length, 306
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

  strategies = Visio.manager.strategies(['ben'])
  strictEqual(strategies.length, 1)
  strictEqual(strategies[0].id, 'ben')

  strategies = Visio.manager.strategies([])
  strictEqual(strategies.length, 3)
)
