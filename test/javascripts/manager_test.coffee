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
