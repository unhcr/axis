module 'Global Router',
  setup: ->
    # Use Overview router because overview router is meant to be inherited
    stop()
    Visio.user = new Visio.Models.User()
    Visio.manager = new Visio.Models.Manager({
      ready: ->
        Visio.router = new Visio.Routers.GlobalRouter()
        Backbone.history.start({ silent: true}) unless Backbone.History.started
        start()

    })
  teardown: ->
    Visio.manager.get('db').clear()
    Visio.router.exportView?.close()
