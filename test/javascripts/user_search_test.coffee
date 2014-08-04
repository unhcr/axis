module 'User Search',
  setup: () ->
    Visio.user = new Visio.Models.User()
    Visio.manager = new Visio.Models.Manager()

    @view = new Visio.Views.UserSearch()
    @server = sinon.fakeServer.create()

    models = [{ login: 'abc', id: 2 }, { login: 'adef', id: 1 }]
    @server.respondWith 'GET', /.*/,  (req) ->

      [200, {'Content-Type': 'application/json'}, JSON.stringify(models)]

  teardown: () ->
    @server.restore()
    Visio.manager.get('db').clear()

asyncTest 'search - with results', ->

  @view.render()

  @view.search('abc').done =>
    strictEqual @view.$el.find('.user-search-result').length, 2
    start()

  @server.respond()

asyncTest 'search - erase results', ->

  @view.render()

  @view.search('abc').done =>
    strictEqual @view.$el.find('.user-search-result').length, 2

    @view.search()
    strictEqual @view.$el.find('.user-search-result').length, 0
    start()

  @server.respond()

