module 'Map Model',
  setup: ->
    Visio.manager = new Visio.Models.Manager()
    Visio.mapMD5 = 'abc123'
    @map = new Visio.Models.Map()

  teardown: ->
    Visio.manager.get('db').clear()

asyncTest 'getMap', ->
  sinon.stub $, 'get', (url, options) ->
    if url == '/map'
      return { object: 'my map object' }

  @map.getMap().done( =>
    # Should retreive via ajax
    ok $.get.calledOnce, 'Should have been called once at this point'
    ok @map.get('map')?, 'Should have map'
  ).done(() =>
    @map.getMap()
  ).done((map) ->
    # Should retreive local
    ok $.get.calledOnce, 'Should not have been called a second time'
    ok(map, 'Should have map')
    $.get.restore()
    start()
  )

asyncTest 'getMap - no local storage', ->
  Visio.manager.set 'use_local_db', false

  sinon.stub $, 'get', (url, options) ->
    if url == '/map'
      return $.Deferred().resolve({ object: 'my map object' }).promise()

  @map.getMap().done( =>
    ok $.get.calledOnce, 'Should have been called once at this point'
    ok @map.get('map')?, 'Should have map'
    strictEqual @map.get('map').object, 'my map object'
  ).done( =>
    @map.getMap()
  ).done( =>
    ok $.get.calledOnce, 'Should have been called once at this point'
    # Use the map that has already been set in model
    ok @map.get('map')?, 'Should have map'
    strictEqual @map.get('map').object, 'my map object'
    $.get.restore()
    start()
  )
