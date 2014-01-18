module 'Syncable',
  setup: ->
    Visio.user = new Visio.Models.User()
    Visio.manager = new Visio.Models.Manager()

    @syncables = _.values(Visio.Parameters).concat _.values(Visio.Syncables)

  teardown: () ->
    Visio.manager.get('db').clear()

asyncTest 'fetchSynced', ->

  sinon.stub $, 'get', (url, options) ->
    if options.synced_timestamp
      return { new: [], updated: [{ id: 20, attr: 'dummy' }], deleted: [] }
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
      strictEqual collection.get(20).get('attr'), 'dummy', "#{syncable.human} should have updated collection"
      count += 1
      if count == @syncables.length
        start()
        $.get.restore()
