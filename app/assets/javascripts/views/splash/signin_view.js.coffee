class Visio.Views.SigninView extends Backbone.View

  template: HAML['splash/signin']

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

    $login = @$el.find('.login')
    $password = @$el.find('.password')

    login = $login.val()
    password = $password.val()


    Visio.Utils.flash($login, 'Please enter valid username') unless login
    Visio.Utils.flash($password, 'This field is required') unless password

    if login && password
      Visio.Utils.signin(login, password, () =>
        window.location.href = '/'
      )

  onFocus: (e) ->
    $('body').addClass('ui-primary-dark-theme')
    $('body').removeClass('ui-primary-theme')

  onBlur: (e) ->
    $('body').addClass('ui-primary-theme')
    $('body').removeClass('ui-primary-dark-theme')


