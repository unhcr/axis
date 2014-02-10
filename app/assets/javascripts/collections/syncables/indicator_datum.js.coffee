class Visio.Collections.IndicatorDatum extends Visio.Collections.Syncable

  model: Visio.Models.IndicatorDatum

  name: Visio.Syncables.INDICATOR_DATA

  url: '/indicator_data'

  situationAnalysis: (reported) ->

    reported ||= Visio.Algorithms.REPORTED_VALUES.myr

    counts = {}
    counts[Visio.Algorithms.ALGO_RESULTS.success] = 0
    counts[Visio.Algorithms.ALGO_RESULTS.ok] = 0
    counts[Visio.Algorithms.ALGO_RESULTS.fail] = 0
    counts[Visio.Algorithms.STATUS.missing] = 0

    @each((datum) ->
      result = datum.situationAnalysis()

      if result.include and result.status == Visio.Algorithms.STATUS.reported
        counts[result.category] += 1
      else if result.include and result.status == Visio.Algorithms.STATUS.missing
        counts[result.status] += 1
    )

    count = counts[Visio.Algorithms.ALGO_RESULTS.success] +
            counts[Visio.Algorithms.ALGO_RESULTS.ok] +
            counts[Visio.Algorithms.ALGO_RESULTS.fail]

    result = (counts[Visio.Algorithms.ALGO_RESULTS.success] / count) +
             (0.5 * (counts[Visio.Algorithms.ALGO_RESULTS.ok] / count))


    if result >= Visio.Algorithms.SUCCESS_THRESHOLD
      category = Visio.Algorithms.ALGO_RESULTS.success
    else if result >= Visio.Algorithms.OK_THRESHOLD
      category = Visio.Algorithms.ALGO_RESULTS.ok
    else
      category = Visio.Algorithms.ALGO_RESULTS.fail

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
      console.log result

      if result.include and result.status == Visio.Algorithms.STATUS.reported
        results.push(result.result)

    average = _.reduce(results,
      (sum, num) -> return sum + num,
      0) / results.length


    divisor = if reported == Visio.Algorithms.REPORTED_VALUES.yer then 1 else 2

    if average >= Visio.Algorithms.HIGH_THRESHOLD / divisor
      category = Visio.Algorithms.ALGO_RESULTS.high
    else if average >= Visio.Algorithms.MEDIUM_THRESHOLD / divisor
      category = Visio.Algorithms.ALGO_RESULTS.medium
    else
      category = Visio.Algorithms.ALGO_RESULTS.low

    result = {
      category: category
      result: average
    }

    console.log result

    result
