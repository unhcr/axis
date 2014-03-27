Visio.Utils.signin = (login, password) ->
  data =
    remote: true
    commit: "Sign in"
    utf8: "✓"
    user:
      remember_me: 1
      password: password
      login: login

  $.post('/users/sign_in.json', data)


Visio.Utils.signup = (firstname, lastname, login, password, passwordConf, callback) ->
  data =
    remote: true
    commit: "Sign up"
    utf8: "✓"
    user:
      remember_me: 1
      password: password
      password_confirmation: passwordConf
      login: login
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

Visio.Utils.humanMetric = (metric) ->
  if metric == Visio.Algorithms.REPORTED_VALUES.myr
    return 'MYR'
  else if metric == Visio.Algorithms.REPORTED_VALUES.yer
    return 'YER'
  else if metric == Visio.Algorithms.REPORTED_VALUES.baseline
    return 'Baseline'
  else if metric == Visio.Algorithms.GOAL_TYPES.target
    return 'Target'
  else if metric == Visio.Algorithms.GOAL_TYPES.standard
    return 'Standard'
  else if metric == Visio.Algorithms.ALGO_RESULTS.success
    return 'Acceptable'
  else if metric == Visio.Algorithms.ALGO_RESULTS.ok
    return 'Critical'
  else if metric == Visio.Algorithms.ALGO_RESULTS.fail
    return 'Sub-standard'
  else if metric == Visio.Algorithms.STATUS.missing
    return 'Non-reported'
  else if metric == Visio.Algorithms.ALGO_RESULTS.high
    return 'Met Target'
  else if metric == Visio.Algorithms.ALGO_RESULTS.medium
    return 'Approaching Target'
  else if metric == Visio.Algorithms.ALGO_RESULTS.low
    return 'Below Target'
  else if metric == Visio.Algorithms.STATUS.missing
    return 'Not Reported'
  else
    return 'N/A'

Visio.Utils.nl2br = (string) ->
  string.replace(/\n/g, '<br />')

Visio.Utils.space2nbsp = (string) ->
  string.replace(/\ /g, '&nbsp;')

Visio.Utils.generateOverviewUrl = ->
  [Visio.router.moduleView.id,
   Visio.manager.year(),
   Visio.manager.get('aggregation_type'),
   Visio.manager.get('reported_type')].join '/'
