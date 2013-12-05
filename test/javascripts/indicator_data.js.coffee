module 'Indicator Data',
  setup: () ->
    Visio.manager = new Visio.Models.Manager()

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

test 'achievement collection', () ->
  Visio.manager.get('outputs').reset([
    {
      id: 'present'
      ol_budget: 40
    }
  ])
  Visio.manager.get('problem_objectives').reset([
    {
      id: 'present'
      ol_budget: 40
    }
  ])

  data = new Visio.Collections.IndicatorDatum()
  data.reset([{
      id: 'ben'
      output_id: 'present'
      problem_objective_id: 'present'
      is_performance: true
      myr: 50
      comp_target: 50
      reversal: false
      baseline: 20
    },
    {
      id: 'lisa'
      output_id: 'present'
      problem_objective_id: 'present'
      is_performance: true
      myr: 50
      comp_target: 100
      reversal: false
      baseline: 25
    }
  ])

  result = data.achievement()

  strictEqual(.75, result.result)
  strictEqual(Visio.Algorithms.ALGO_RESULTS.high, result.category)

  data.get('ben').set({
    baseline: 100
    comp_target: 100
    is_performance: false
  })

  result = data.achievement()
  strictEqual(Visio.Algorithms.ALGO_RESULTS.low, result.category)

test 'achievement', () ->
  Visio.manager.get('outputs').reset([
    {
      id: 'present'
      ol_budget: 40
    }
  ])
  Visio.manager.get('problem_objectives').reset([
    {
      id: 'present'
      ol_budget: 40
    }
  ])
  datum = new Visio.Models.IndicatorDatum({
    id: 'ben'
    output_id: 'present'
    problem_objective_id: 'present'
    is_performance: true
    myr: 50
    comp_target: 50
    reversal: true
    baseline: 20
  })

  strictEqual(1, datum.achievement())

  datum.set('comp_target', 40)
  strictEqual(1, datum.achievement())

  datum.set('is_performance', false)
  strictEqual(0, datum.achievement())

  datum.set('baseline', 100)
  datum.set('comp_target', 50)
  strictEqual(1 , datum.achievement())

  datum.set('comp_target', 25)
  strictEqual(50/75 , datum.achievement())

  datum.set('reversal', false)
  datum.set('baseline', 50)
  datum.set('myr', 50)
  datum.set('comp_target', 50)

  strictEqual(1, datum.achievement())

  datum.set('comp_target', 100)

  strictEqual(0, datum.achievement())






test 'missingBudget', () ->
  Visio.manager.get('outputs').reset([
    {
      id: 'zero'
      ol_budget: 0
    },
    {
      id: 'missing'
      ol_budget: undefined
    },
    {
      id: 'present'
      ol_budget: 40
    }
  ])
  Visio.manager.get('problem_objectives').reset([
    {
      id: 'zero'
      ol_budget: 0
    },
    {
      id: 'missing'
      ol_budget: undefined
    },
    {
      id: 'present'
      ol_budget: 40
    }
  ])


  datum = new Visio.Models.IndicatorDatum({
    id: 'ben'
    output_id: 'zero'
    problem_objective_id: 'present'
    is_performance: true
  })

  ok(datum.missingBudget())

  datum.set('output_id', 'missing')
  ok(datum.missingBudget())

  datum.set('output_id', 'present')
  ok(!datum.missingBudget())

  datum.set('is_performance', false)
  ok(!datum.missingBudget())

  datum.set('problem_objective_id', 'missing')
  ok(datum.missingBudget())

  datum.set('problem_objective_id', 'zero')
  ok(datum.missingBudget())
