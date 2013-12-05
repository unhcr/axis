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
    return Visio.Algorithms.ALGO_COLORS.success
  else if result >= Visio.Algorithms.OK_THRESHOLD
    return Visio.Algorithms.ALGO_COLORS.ok
  else
    return Visio.Algorithms.ALGO_COLORS.fail
