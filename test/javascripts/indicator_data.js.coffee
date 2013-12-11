module 'Indicator Data',
  setup: () ->
    Visio.manager = new Visio.Models.Manager()

test 'achievement collection', () ->
  Visio.manager.get('outputs').reset([
    {
      id: 'present'
      budget: 40
    }
  ])
  Visio.manager.get('problem_objectives').reset([
    {
      id: 'present'
      budget: 40
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
      standard: 60
      reversal: false
      baseline: 20
      missing_budget: false
    },
    {
      id: 'lisa'
      output_id: 'present'
      problem_objective_id: 'present'
      is_performance: true
      myr: 50
      comp_target: 100
      standard: 20
      reversal: false
      baseline: 25
      missing_budget: false
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

  Visio.manager.set 'achievement_type', Visio.AchievementTypes.STANDARD
  data.get('ben').set({
    baseline: 20
    is_performance: false
  })
  data.get('lisa').set({
    is_performance: false
    baseline: 40
  })

  result = data.achievement()
  strictEqual(.875, result.result)
  strictEqual(Visio.Algorithms.ALGO_RESULTS.high, result.category)

test 'achievement', () ->
  Visio.manager.get('outputs').reset([
    {
      id: 'present'
      budget: 40
    }
  ])
  Visio.manager.get('problem_objectives').reset([
    {
      id: 'present'
      budget: 40
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
