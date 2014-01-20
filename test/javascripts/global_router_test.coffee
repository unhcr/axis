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

test 'search', ->

  Visio.router.search()

  strictEqual $(document).scrollTop(), 0, 'ScrollTop should be 0 after navigating to search'


test 'menu', ->


  Visio.router.menu()
  ok !window.location.hash, 'There should not be a url fragment'
  ok !Visio.router.menuView.isHidden(), 'Should be showing'


  Visio.router.menu()
  ok !window.location.hash, 'There should not be a url fragment'
  ok Visio.router.menuView.isHidden(), 'Should be hidden'

