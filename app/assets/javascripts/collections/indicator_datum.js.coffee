class Visio.Collections.IndicatorDatum extends Visio.Collections.Parameter

  model: Visio.Models.IndicatorDatum

  name: Visio.Parameters.INDICATOR_DATA

  url: '/indicator_data'

  situation_analysis: (strategy_ids) ->
    strategies = Visio.manager.strategies(strategy_ids)
    data = @filter((datum) ->
      return _.include(_.flatten(strategies.pluck('plans_ids')), datum.get('plan_id')) &&
        _.include(_.flatten(strategies.pluck('ppgs_ids')), datum.get('ppg_id')) &&
        _.include(_.flatten(strategies.pluck('goals_ids')), datum.get('goal_id')) &&
        _.include(_.flatten(strategies.pluck('outputs_ids')), datum.get('output_id')) &&
        _.include(_.flatten(strategies.pluck('problem_objectives_ids')), datum.get('problem_objective_id')) &&
        _.include(_.flatten(strategies.pluck('indicators_ids')), datum.get('indicator_id')) &&
        !datum.get('is_performance')

    )

    return Visio.Algorithms.situation_analysis(data, 'myr')


