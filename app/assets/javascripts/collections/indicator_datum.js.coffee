class Visio.Collections.IndicatorDatum extends Visio.Collections.Parameter

  model: Visio.Models.IndicatorDatum

  name: Visio.Parameters.INDICATOR_DATA

  url: '/indicator_data'

  situation_analysis: (reported_value) ->
    reported_value ||= Visio.Algorithms.REPORTED_VALUES.myr

    counts = {}
    counts[Visio.Algorithms.ALGO_RESULTS.success] = 0
    counts[Visio.Algorithms.ALGO_RESULTS.ok] = 0
    counts[Visio.Algorithms.ALGO_RESULTS.fail] = 0
    counts[Visio.Algorithms.ALGO_RESULTS.missing] = 0

    @each((datum) ->
      counts[datum.situation_analysis()] += 1
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

    return {
      result: result
      category: category
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

  budget: () ->
    return null unless @length > 0

    problem_objective_ids = _.uniq(@pluck('problem_objective_id'))

    problem_objectives = Visio.manager.get('problem_objectives').filter((p) ->
      _.include(problem_objective_ids, p.id) )

    _.reduce(problem_objectives,
      (sum, p) -> return sum + p.budget(),
      0)

