module 'Indicator Data',
  setup: () ->
    Visio.manager = new Visio.Models.Manager()

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
