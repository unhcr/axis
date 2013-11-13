class Visio.Routers.SplashRouter extends Backbone.Router

  initialize: () ->
    console.log 'starting'

  routes: () ->
    'signin': 'signin'
    'signup': 'signup'
    '*default': 'signin'

  signin: () ->
    @signin = new Visio.Views.SigninView({ el: $('.session-container') })

  signup: () ->
    @signup = new Visio.Views.SignupView()

