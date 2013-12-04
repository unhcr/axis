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


