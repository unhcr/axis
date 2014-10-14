class Visio.Routers.IndexRouter extends Backbone.Router

  initialize: (options) ->
    super
    height = $(window).height() - $('header').height()

    @menuView = new Visio.Views.MenuView
      el: $('.menu-container')

    @settings?.close()
    @settings = new Visio.Views.Settings
      model: Visio.user

    $('.user-account').html @settings.render().el

    @setup()

  routes:
    'search': 'search'
    'menu': 'menu'
    '*default': 'index'

  index: ->
    console.log 'index'

  setup: =>
    Visio.manager.set 'setup', true
