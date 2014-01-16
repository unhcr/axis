module 'Indicator Data',
  setup: () ->
    Visio.user = new Visio.Models.User()
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
    missing_budget: false
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

test 'situation analysis', () ->
  datum = new Visio.Models.IndicatorDatum({
    id: 'ben'
    output_id: 'present'
    problem_objective_id: 'present'
    is_performance: false
    myr: 50
    threshold_green: 60
    threshold_red: 40
  })

  res = datum.situationAnalysis()
  strictEqual res, Visio.Algorithms.ALGO_RESULTS.ok

  datum.set('myr', 60)
  res = datum.situationAnalysis()
  strictEqual res, Visio.Algorithms.ALGO_RESULTS.success

  datum.set('myr', 30)
  res = datum.situationAnalysis()
  strictEqual res, Visio.Algorithms.ALGO_RESULTS.fail

  datum.set 'is_performance', true
  throws datum.situationAnalysis, 'Should throw an error'

test 'situation analysis collection', () ->
  data = new Visio.Collections.IndicatorDatum([{
    id: 'ben'
    output_id: 'present'
    problem_objective_id: 'present'
    is_performance: false
    myr: 50
    threshold_green: 60
    threshold_red: 40
  },{
    id: 'lisa'
    output_id: 'present'
    problem_objective_id: 'present'
    is_performance: false
    myr: 50
    threshold_green: 60
    threshold_red: 40
  }

  ])

  res = data.situationAnalysis()
  strictEqual res.category, Visio.Algorithms.ALGO_RESULTS.ok
  strictEqual res.result, .5
  strictEqual res.total, 2
  strictEqual res.counts[Visio.Algorithms.ALGO_RESULTS.ok], 2

  data.at(0).set('myr', 60)
  res = data.situationAnalysis()
  strictEqual res.category, Visio.Algorithms.ALGO_RESULTS.success
  strictEqual res.total, 2
  strictEqual res.counts[Visio.Algorithms.ALGO_RESULTS.ok], 1
  strictEqual res.counts[Visio.Algorithms.ALGO_RESULTS.success], 1

  data.at(0).set('myr', 30)
  res = data.situationAnalysis()
  strictEqual res.category, Visio.Algorithms.ALGO_RESULTS.fail
  strictEqual res.total, 2
  strictEqual res.counts[Visio.Algorithms.ALGO_RESULTS.ok], 1
  strictEqual res.counts[Visio.Algorithms.ALGO_RESULTS.fail], 1

  data2 = data.clone()
  data2.remove(data2.get('lisa'))

  data.get('lisa').set 'is_performance', true

  res = data.situationAnalysis()
  res2 = data2.situationAnalysis()

  strictEqual res.category, res2.category, 'Each category should be the same'
  strictEqual res.result, res2.result, 'Each results shoudl be the same'
  strictEqual res.total, res2.total, 'Each total should be the same'
  strictEqual res.counts[Visio.Algorithms.ALGO_RESULTS.ok],
              res2.counts[Visio.Algorithms.ALGO_RESULTS.ok], 'Counts should be the same'

  data = new Visio.Collections.IndicatorDatum()
  res = data.situationAnalysis()
  strictEqual res.category, Visio.Algorithms.ALGO_RESULTS.fail
  strictEqual res.result, 0
  strictEqual res.total, 0
  strictEqual res.counts[Visio.Algorithms.ALGO_RESULTS.ok], 0




test 'isConsistent', () ->
  datum = new Visio.Models.IndicatorDatum({
    baseline: 0
    myr: 10
    yer: 20
  })

  ok datum.isConsistent(datum), 'Should be consistent'

  datum.set 'baseline', 20
  ok !datum.isConsistent(datum), 'Should not be consistent'

  datum.set 'baseline', 0
  datum.set 'yer', 5
  ok !datum.isConsistent(datum), 'Should not be consistent'

  datum.set 'yer', null
  ok datum.isConsistent(datum), 'Should be consistent'
