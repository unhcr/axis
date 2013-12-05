module 'Indicator Data'

test 'situation analysis', () ->

  data = new Visio.Collections.IndicatorDatum([
    {
      id: 1
      yer: 20
      myr: 8
      threshold_green: 10
      threshold_red: 5
      plan_id: 1
      goal_id: 1
      output_id: 1
      ppg_id: 1
      problem_objective_id: 1
      indicator_id: 1
      is_performance: false
    },
    {
      id: 2
      yer: 30
      myr: 21
      threshold_green: 40
      threshold_red: 20
      plan_id: 2
      goal_id: 2
      output_id: 2
      ppg_id: 2
      problem_objective_id: 2
      indicator_id: 2
      is_performance: false
    },
    {
      id: 3
      yer: 30
      myr: 21
      threshold_green: 40
      threshold_red: 20
      plan_id: 2
      goal_id: 2
      output_id: 2
      ppg_id: 2
      problem_objective_id: 2
      indicator_id: 2
      is_performance: true
    },
    {
      id: 3
      yer: 30
      myr: 21
      threshold_green: 40
      threshold_red: 20
      plan_id: 2
      goal_id: 3
      output_id: 2
      ppg_id: 2
      problem_objective_id: 2
      indicator_id: 2
      is_performance: false
    }
  ])

  color = data.situation_analysis(
      plans_ids: [1, 2]
      ppgs_ids: [1, 2]
      goals_ids: [1, 2]
      outputs_ids: [1, 2]
      problem_objectives_ids: [1, 2]
      indicators_ids: [1, 2]
    , 'yer')
  strictEqual color, Visio.Algorithms.ALGO_RESULTS.success


  color = data.situation_analysis(
      plans_ids: [1, 2]
      ppgs_ids: [1, 2]
      goals_ids: [1, 2]
      outputs_ids: [1, 2]
      problem_objectives_ids: [1, 2]
      indicators_ids: [1, 2]
    , 'myr')
  strictEqual color, Visio.Algorithms.ALGO_RESULTS.ok




