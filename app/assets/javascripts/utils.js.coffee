Visio.Utils.signin = (email, password, callback) ->
  assert(typeof email == 'string', 'Email must be string')
  assert(typeof password == 'string', 'Password must be string')

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


Visio.Utils.signup = (firstname, lastname, email, password, passwordConf, callback) ->
  assert(typeof firstname == 'string', 'Name must be string')
  assert(typeof lastname == 'string', 'Name must be string')
  assert(typeof email == 'string', 'Email must be string')
  assert(typeof password == 'string', 'Password must be string')
  assert(typeof passwordConf == 'string', 'PasswordConf must be string')

  data =
    remote: true
    commit: "Sign up"
    utf8: "✓"
    user:
      remember_me: 1
      password: password
      password_confirmation: passwordConf
      email: email
      firstname: firstname
      lastname: lastname

  $.post('/users', data, (resp) ->
    console.log resp
    if callback
      callback(resp)
  )

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

