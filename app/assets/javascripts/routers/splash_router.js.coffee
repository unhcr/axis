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
    $('body').addClass 'ui-primary-theme'
    $('body').removeClass 'ui-primary-medium-theme'
    @signin = new Visio.Views.SigninView({ el: el })
    el.show()

  signup: () ->
    el = $('.signup')
    $('.session-container').hide()
    $('body').addClass 'ui-primary-medium-theme'
    $('body').removeClass 'ui-primary-theme'
    @signup = new Visio.Views.SignupView({ el: el })
    el.show()

