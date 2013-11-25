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
    ok(record.synced_date, 'Should have a sync date')
    start()
  )

)

asyncTest('setLastSync', () ->
  s = new Date()

  Visio.manager.setSyncDate().done(() ->
    return Visio.manager.getSyncDate()
    ).then((record) ->
      ok(+record.synced_date >= +s, 'Should always be less than sync date')
      start()
    )
)

asyncTest('setSyncedPlans', () ->
  plans = {
    new: [{ id: 'bob', name: 'george' }, { id: 'wendy', name: 'sue' }]
    deleted: []
    updated: []
  }

  Visio.manager.setSyncedPlans(plans).done(() ->
    return Visio.manager.getSyncedPlans()
  ).done((records) ->
    strictEqual(2, records.length, 'length of plans')
    plans.new = []
    plans.updated = [{ id: 'bob', name: 'matt' }]
    plans.deleted = [{ id: 'wendy', name: 'sue' }]

    return Visio.manager.setSyncedPlans(plans)
  ).done(() ->
    return Visio.manager.getSyncedPlans()
  ).done((records) ->
    strictEqual('matt', records[0].name, 'Update 1 plan')
    strictEqual(1, records.length, 'Deleted 1 plan')
    start()
  )


)

