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

    $email = @$el.find('.email')
    $password = @$el.find('.password')

    email = $email.val()
    password = $password.val()


    Visio.Utils.flash($email, 'Please enter valid email address') unless email
    Visio.Utils.flash($password, 'This field is required') unless password

    if email && password
      Visio.Utils.signin(email, password, () =>
        window.location.href = '/'
      )

  onFocus: (e) ->
    $('body').addClass('ui-primary-dark-theme')
    $('body').removeClass('ui-primary-theme')

  onBlur: (e) ->
    $('body').addClass('ui-primary-theme')
    $('body').removeClass('ui-primary-dark-theme')


