class Visio.Routers.SplashRouter extends Backbone.Router

  initialize: () ->
    console.log 'starting'

  routes: () ->
    'signin': 'signin'
    'signup': 'signup'
    '*default': 'signin'

  signin: () ->
    el = $('.signin')
    $('.session-container').hide()
    @signin = new Visio.Views.SigninView({ el: el })
    el.slideDown()

  signup: () ->
    el = $('.signup')
    $('.session-container').hide()
    @signup = new Visio.Views.SignupView({ el: $('.signup') })
    el.slideDown()

