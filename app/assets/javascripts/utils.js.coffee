Visio.Utils.signin = (email, password, callback) ->
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
    if callback
      callback(resp)
  )
  return false


Visio.Utils.signup = (email, password, passwordConf, callback) ->
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

Visio.Utils.signout = (callback) ->

  $.ajax(
    url: '/users/sign_out',
    type: 'DELETE',
    success: (resp) ->
      console.log(resp)
      if callback
        callback(resp)
    error: (resp) ->
      console.log(resp)
      if callback
        callback(resp))

