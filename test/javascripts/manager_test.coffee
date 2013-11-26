module 'Manager',

  setup: () ->
    stop()
    Visio.manager = new Visio.Models.Manager()
    start()

  teardown: () ->
    Visio.manager.get('db').clear()

asyncTest('getLastSync', () ->
  Visio.manager.setSyncDate().done((key) ->
    return Visio.manager.getSyncDate()
  ).done((record) ->
    ok(record.synced_timestamp, 'Should have a sync date')
    start()
  )

)

asyncTest('setLastSync', () ->
  s = new Date()

  Visio.manager.setSyncDate().done(() ->
    return Visio.manager.getSyncDate()
    ).then((record) ->
      ok(+record.synced_timestamp >= +s, 'Should always be less than sync date')
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
