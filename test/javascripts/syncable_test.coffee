module 'Syncable',
  setup: ->
    Visio.user = new Visio.Models.User()
    Visio.manager = new Visio.Models.Manager()

    @syncables = _.values(Visio.Parameters).concat _.values(Visio.Syncables)

  teardown: () ->
    Visio.manager.get('db').clear()

asyncTest 'fetchSynced', ->
  expect @syncables.length * 3

  sinon.stub $, 'get', (url, options) ->
    if options.synced_timestamp
      return { new: [], updated: [{ id: 20, attr: 'dummy' }], deleted: [{ id: 'abc-efg' }] }
    else
      return { new: [{ id: 20 }, { id: 'abc-efg' }], updated: [], deleted: [] }

  # Poor man's thread control
  count = 0
  _.each @syncables, (syncable) =>
    collection = new Visio.Collections[syncable.className]()

    collection.fetchSynced().done(->
      strictEqual collection.models.length, 2, "#{syncable.human} should have 2 models"

      return collection.fetchSynced()
    ).done =>
      strictEqual collection.models.length, 1, "#{syncable.human} should have 1 models"
      strictEqual collection.get(20).get('attr'), 'dummy', "#{syncable.human} should have updated collection"
      count += 1
      if count == @syncables.length
        $.get.restore()
        start()

asyncTest 'fetchSynced - no local storage', ->
  Visio.manager.set 'use_local_db', false

  regex = new RegExp @syncables.map((s) -> s.plural).join('|')
  models = [{ id: 20 }, { id: 'abc-efg' }]
  sinon.spy $, 'get'

  server = sinon.fakeServer.create()
  server.respondWith 'GET', regex, [200, {'Content-Type': 'application/json'}, JSON.stringify(models)]

  # Poor man's thread control
  count = 0
  _.each @syncables, (syncable) =>
    collection = new Visio.Collections[syncable.className]()

    sinon.spy collection, 'fetch'

    collection.fetchSynced().done =>
      strictEqual collection.models.length, 2, "#{syncable.human} should have 2 models"
      strictEqual $.get.callCount, 0, "#{syncable.human} should not have called ajax get"

      ok collection.fetch.calledOnce, 'Should have called fetch, not fetchSynced'

      collection.fetch.restore()

      count += 1
      if count == @syncables.length
        $.get.restore()
        server.restore()
        start()

    server.respond()

