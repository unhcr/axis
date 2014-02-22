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

    $login = @$el.find('.login')
    $password = @$el.find('.password')

    login = $login.val()
    password = $password.val()


    Visio.Utils.flash($login, 'Please enter valid username') unless login
    Visio.Utils.flash($password, 'This field is required') unless password

    if login && password
      Visio.Utils.signin(login, password).done (resp) =>
        if resp.success
          window.location.href = '/'
        else
          $login.val('')
          $password.val('')
          Visio.Utils.flash($login, 'Authentication Failed')
          Visio.Utils.flash($password, 'Authentication Failed')


  onFocus: (e) ->
    $('body').addClass('ui-primary-dark-theme')
    $('body').removeClass('ui-primary-theme')

  onBlur: (e) ->
    $('body').addClass('ui-primary-theme')
    $('body').removeClass('ui-primary-dark-theme')


