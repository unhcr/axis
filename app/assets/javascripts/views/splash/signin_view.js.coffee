class Visio.Views.SigninView extends Backbone.View

  template: JST['splash/signin']

  events:
    'click .signin' : 'onClickSignin'
    'focus input' : 'onFocus'
    'blur input' : 'onBlur'

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
    Visio.Utils.signin(email, password, () =>
      window.location.href = '/'
    )

  onFocus: (e) ->
    $('body').addClass('ui-primary-dark-theme')
    $('body').removeClass('ui-primary-theme')

  onBlur: (e) ->
    $('body').addClass('ui-primary-theme')
    $('body').removeClass('ui-primary-dark-theme')


