class Visio.Views.SignupView extends Backbone.View

  template: JST['splash/signup']

  events:
    'click .signup' : 'onClickSignup'

  initialize: () ->
    @render()

  render: () ->
    @$el.html @template()
    @

  onClickSignup: (e) ->
    e.preventDefault()
    e.stopPropagation()

    console.log 'clicked signup'

    email = @$el.find('.email').val()
    password = @$el.find('.password').val()
    passwordConf = @$el.find('.password-confirmation').val()
    firstname = @$el.find('.firstname').val()
    lastname = @$el.find('.lastname').val()

    Visio.Utils.signup(firstname, lastname, email, password, passwordConf, () =>
      window.location.href = '/'
    )
