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
    @signup(email, password, passwordConf, () =>
      window.location.href = '/'
    )

  signup: (email, password, passwordConf, callback) =>
    data =
      remote: true
      commit: "Sign up"
      utf8: "✓"
      user:
        remember_me: 1
        password: password
        password_confirmation: passwordConf
        email: email

    $.post('/users', data, (resp) ->
      console.log resp
      if callback
        callback(resp)
    )
    return false


