class Visio.Views.SignupView extends Backbone.View

  template: JST['splash/signup']

  events:
    'click .signup' : 'onClickSignup'
    'focus input' : 'onFocus'
    'blur input' : 'onBlur'

  initialize: () ->
    @render()

  render: () ->
    @$el.html @template()
    @

  onClickSignup: (e) ->
    e.preventDefault()
    e.stopPropagation()

    console.log 'clicked signup'

    $email = @$el.find('.email')
    $password = @$el.find('.password')
    $passwordConf = @$el.find('.password-confirmation')
    $firstname = @$el.find('.firstname')
    $lastname = @$el.find('.lastname')

    Visio.Utils.flash($email, 'This field is required') unless $email.val()
    Visio.Utils.flash($password, 'This field is required') unless $password.val()
    Visio.Utils.flash($passwordConf, 'This field is required') unless $passwordConf.val()
    Visio.Utils.flash($firstname, 'This field is required') unless $firstname.val()
    Visio.Utils.flash($lastname, 'This field is required') unless $lastname.val()


    if $email.val() && $password.val() && $passwordConf.val() && $firstname.val() && $lastname.val()
      Visio.Utils.signup($firstname.val(), $lastname.val(), $email.val(), $password.val(), $passwordConf.val(), () =>
        window.location.href = '/'
      )

  onFocus: (e) ->
    $('body').addClass('ui-primary-medium-dark-theme')
    $('body').removeClass('ui-primary-medium-theme')

  onBlur: (e) ->
    $('body').addClass('ui-primary-medium-theme')
    $('body').removeClass('ui-primary-medium-dark-theme')
