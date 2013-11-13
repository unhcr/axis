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
    Visio.Utils.signin(email, password)

