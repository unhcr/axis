module 'Strategy CMS Router',
  setup: ->
    stop()
    Visio.user = new Visio.Models.User()
    Visio.manager = new Visio.Models.Manager({
      strategies: new Visio.Collections.Strategy([
        { id: 1, ppgs: [] },
        { id: 2, ppgs: [] }
      ]),
      ready: ->
        Visio.router = new Visio.Routers.StrategyCMSRouter()
        Backbone.history.start({ silent: true}) unless Backbone.History.started
        start()

    })

  teardown: ->
    Visio.manager.get('db').clear()


test 'index', ->
  Visio.router.index()

  strictEqual Visio.router.indexView.$el.find('.strategy').length, 2

