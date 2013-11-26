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
    return Visio.manager.getMap().done((md5) ->
      # Should retreive via ajax
      strictEqual Visio.manager.get('mapMD5'), md5
    ).done(() ->
      Visio.manager.getMap()
    ).done((md5) ->
      # Should retreive local
      strictEqual Visio.manager.get('mapMD5'), md5
      start()
    )
  )
)
