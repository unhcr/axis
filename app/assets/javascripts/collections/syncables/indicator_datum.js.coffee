class Visio.Collections.IndicatorDatum extends Visio.Collections.Syncable

  model: Visio.Models.IndicatorDatum

  name: Visio.Syncables.INDICATOR_DATA.plural

  url: '/indicator_data'

  situationAnalysis: (reported) ->
    reported ||= Visio.Algorithms.REPORTED_VALUES.myr

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

  achievement: (reported) ->
    return { category: null, result: null } if @length == 0
    reported ||= Visio.Algorithms.REPORTED_VALUES.myr
    results = []

    @each (datum) ->
      result = datum.achievement(reported)

      results.push(result) unless result == Visio.Algorithms.ALGO_RESULTS.missing or isNaN(result)

    average = _.reduce(results,
      (sum, num) -> return sum + num,
      0) / results.length

    category = Visio.Algorithms.ALGO_RESULTS.low

    divisor = if reported == Visio.Algorithms.REPORTED_VALUES.yer then 1 else 2

    if average >= Visio.Algorithms.HIGH_THRESHOLD / divisor
      category = Visio.Algorithms.ALGO_RESULTS.high
    else if average >= Visio.Algorithms.MEDIUM_THRESHOLD / divisor
      category = Visio.Algorithms.ALGO_RESULTS.medium

    return {
      category: category
      result: average
    }
