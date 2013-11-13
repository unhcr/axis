class Visio.Views.SigninView extends Backbone.View

  template: JST['splash/signin']

  events:
    'click .signin' : 'onClickSignin'

  initialize: () ->
    @render()

  render: () ->
    @$el.html @template()
    @

  onClickSignin: (e) ->
    e.preventDefault()
    e.stopPropagation()

    console.log 'clicked login'

    email = @$el.find('.email').val()
    password = @$el.find('.password').val()
    @signin(email, password)

  signin: (email, password) =>
    data =
      remote: true
      commit: "Sign in"
      utf8: "✓"
      user:
        remember_me: 1
        password: password
        email: email

    $.post('/users/sign_in.json', data, (resp) ->
      console.log resp
      if (resp.success)
        alert 'authenticated'
      else
        alert 'shit something went wrong'
    )
    return false

