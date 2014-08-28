class Visio.Routers.SplashRouter extends Backbone.Router

  initialize: (options) ->
    @proton = new Visio.Views.ProtonView
      stats: options.stats
      el: $('.data-vis-container')

  routes: () ->
    'signin': 'signin'
    'signup': 'signup'
    '*default': 'signin'

  signin: () ->
    el = $('.signin')

    #$('body').addClass 'ui-primary-theme'
    #$('body').removeClass 'ui-primary-medium-theme'
    @signinView = new Visio.Views.SigninView({ el: el }) unless @signinView
    @proton.render()

    # Need to slide out if signup container exists
    if @signupView
      $signup = $('.signup')
      $signup.show()
      $signup.animate({ left: el.width() }, 500, () =>
        $signup.hide()
        el.fadeIn()
      )
    else
      el.fadeIn()


  signup: () ->
    el = $('.signup')
    $('.signin').hide()
    #$('body').addClass 'ui-primary-medium-theme'
    #$('body').removeClass 'ui-primary-theme'

    @signupView = new Visio.Views.SignupView({ el: el }) unless @signupView

    if @signinView
      el.css('left', el.width())
      el.show()
      el.animate({ left: 0 }, 500)
    else
      el.show()

