class Visio.Collections.IndicatorDatum extends Visio.Collections.Parameter

  model: Visio.Models.IndicatorDatum

  name: Visio.Parameters.INDICATOR_DATA

  url: '/indicator_data'

  situation_analysis: (ids, reported_value) ->
    reported_value ||= 'myr'
    data = new Visio.Collections.IndicatorDatum(@filter((datum) ->
        return _.include(ids.plans_ids, datum.get('plan_id')) &&
          _.include(ids.ppgs_ids, datum.get('ppg_id')) &&
          _.include(ids.goals_ids, datum.get('goal_id')) &&
          _.include(ids.outputs_ids, datum.get('output_id')) &&
          _.include(ids.problem_objectives_ids, datum.get('problem_objective_id')) &&
          _.include(ids.indicators_ids, datum.get('indicator_id')) &&
          !datum.get('is_performance')
      ))

    return Visio.Algorithms.situation_analysis(data, reported_value)

  achievement: (reported_value) ->
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
