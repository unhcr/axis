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

Visio.Utils.flash = ($ele, msg) ->
  $ele.removeClass('flash')

  # Cause a redraw
  $ele[0].offsetWidth = $ele[0].offsetWidth

  $ele.addClass('flash')

  $ele.attr('placeholder', msg)

Visio.Utils.parseTransform = (string) ->
  matchTranslate = string.match(/translate\(([0-9]+,[ ]*[0-9]+)\)/)
  matchScale = string.match(/scale\(([0-9]*\.[0-9]*)\)/)

  if matchTranslate && matchTranslate[1]
    translate = matchTranslate[1].split(',').map((d) -> return +d )

  if matchScale && matchScale[1]
    scale = +matchScale[1]

  return {
    translate: translate || [0, 0]
    scale: scale || 1
  }

Visio.Utils.flash = ($ele, msg) ->
  $ele.removeClass('flash')

  # Cause a redraw
  $ele[0].offsetWidth = $ele[0].offsetWidth

  $ele.addClass('flash')

  $ele.attr('placeholder', msg)

Visio.Utils.countToFormatter = (value) ->
  d3.format('d')(value.toFixed(0)) || 0

Visio.Utils.progressTypeToName = (type) ->
  if type == Visio.ProgressTypes.BASELINE_MYR
    return 'Baseline-MYR'
  else if type == Visio.ProgressTypes.BASELINE_YER
    return 'Baseline-YER'
  else if type == Visio.ProgressTypes.MYR_YER
    return 'MYR-YER'

  return ''

Visio.Utils.commaNumber = d3.format(',d')
