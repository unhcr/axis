class Visio.Routers.SplashRouter extends Backbone.Router

  initialize: (options) ->
    @proton = new Visio.Views.ProtonView
      stats: options.stats
      el: $('.data-vis-container')

  routes: () ->
    'signin': 'signin'
    '*default': 'signin'

  signin: () ->
    el = $('.signin')

    @signinView = new Visio.Views.SigninView({ el: el }) unless @signinView
    @proton.render()
