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
    $('.session-container').removeClass 'ui-primary-light'
    @signin = new Visio.Views.SigninView({ el: el })
    el.show()

  signup: () ->
    el = $('.signup')
    $('.session-container').hide()
    $('.session-container').addClass 'ui-primary-light'
    @signup = new Visio.Views.SignupView({ el: el })
    el.show()

