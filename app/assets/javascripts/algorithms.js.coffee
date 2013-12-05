Visio.Algorithms.situation_analysis = (indicator_data, reported_value) ->
  reported_value ||= 'myr'

  numGreen = 0
  numAmber = 0

  indicator_data.each((datum) ->
    return unless datum.get(reported_value)

    if datum.get(reported_value) >= datum.get('threshold_green')
      numGreen += 1
    else if datum.get(reported_value) >= datum.get('threshold_red')
      numAmber += 1
  )

  count = indicator_data.length

  result = (numGreen / count) + (0.5 * (numAmber / count))

  if result >= Visio.Algorithms.SUCCESS_THRESHOLD
    return Visio.Algorithms.ALGO_RESULTS.success
  else if result >= Visio.Algorithms.OK_THRESHOLD
    return Visio.Algorithms.ALGO_RESULTS.ok
  else
    return Visio.Algorithms.ALGO_RESULTS.fail

Visio.Algorithms.achievement = (indicator_data, reported_value) ->
  reported_value ||= Visio.Algorithms.REPORTED_VALUES.myr
  results = []

  indicator_data.each (datum) ->
    result = datum.achievement(reported_value)

    results.push(result) unless result == Visio.Algorithms.ALGO_RESULTS.missing

  average = _.reduce(results, (sum, num) -> sum + num, 0) / results.length

  category = Visio.Algorithms.ALGO_RESULTS.low

  divisor = if reported_value == Visio.REPORTED_VALUES.yer then 1 else 2

  if average >= Visio.Algorithms.HIGH_THRESHOLD / divisor
    category = Visio.Algorithms.ALGO_RESULTS.high
  else if average >= Visio.Algorithms.MEDIUM_THRESHOLD / divisor
    category = Visio.Algorithms.ALGO_RESULTS.medium

  return {
    category: category
    result: average
  }
