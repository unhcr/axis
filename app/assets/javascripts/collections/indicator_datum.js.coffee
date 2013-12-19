class Visio.Collections.IndicatorDatum extends Visio.Collections.Parameter

  model: Visio.Models.IndicatorDatum

  name: Visio.Parameters.INDICATOR_DATA

  url: '/indicator_data'

  situationAnalysis: (reported_value) ->
    reported_value ||= Visio.Algorithms.REPORTED_VALUES.myr

    counts = {}
    counts[Visio.Algorithms.ALGO_RESULTS.success] = 0
    counts[Visio.Algorithms.ALGO_RESULTS.ok] = 0
    counts[Visio.Algorithms.ALGO_RESULTS.fail] = 0
    counts[Visio.Algorithms.ALGO_RESULTS.missing] = 0

    @each((datum) ->
      counts[datum.situationAnalysis()] += 1
    )

    count = counts[Visio.Algorithms.ALGO_RESULTS.success] +
            counts[Visio.Algorithms.ALGO_RESULTS.ok] +
            counts[Visio.Algorithms.ALGO_RESULTS.fail]

    result = (counts[Visio.Algorithms.ALGO_RESULTS.success] / count) + (0.5 * (counts[Visio.Algorithms.ALGO_RESULTS.ok] / count))
    category = Visio.Algorithms.ALGO_RESULTS.fail

    if result >= Visio.Algorithms.SUCCESS_THRESHOLD
      category = Visio.Algorithms.ALGO_RESULTS.success
    else if result >= Visio.Algorithms.OK_THRESHOLD
      category = Visio.Algorithms.ALGO_RESULTS.ok

    result = if isNaN(result) then 0 else result
    return {
      result: result
      category: category
      counts: counts
      total: count
    }

  achievement: (reported_value) ->
    return { category: null, result: null } if @length == 0
    reported_value ||= Visio.Algorithms.REPORTED_VALUES.myr
    results = []

    @each (datum) ->
      result = datum.achievement(reported_value)

      results.push(result) unless result == Visio.Algorithms.ALGO_RESULTS.missing

    average = _.reduce(results,
      (sum, num) -> return sum + num,
      0) / results.length

    category = Visio.Algorithms.ALGO_RESULTS.low

    divisor = if reported_value == Visio.Algorithms.REPORTED_VALUES.yer then 1 else 2

    if average >= Visio.Algorithms.HIGH_THRESHOLD / divisor
      category = Visio.Algorithms.ALGO_RESULTS.high
    else if average >= Visio.Algorithms.MEDIUM_THRESHOLD / divisor
      category = Visio.Algorithms.ALGO_RESULTS.medium

    return {
      category: category
      result: average
    }
