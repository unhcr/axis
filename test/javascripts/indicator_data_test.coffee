module 'Indicator Data',
  setup: () ->
    Visio.user = new Visio.Models.User()
    Visio.manager = new Visio.Models.Manager()
    Visio.manager.set 'reported_type', Visio.Algorithms.REPORTED_VALUES.myr

test 'sum', ->
  data = new Visio.Collections.IndicatorDatum()
  data.reset([
    { id: 'high1', myr: 50, year: 2012 },
    { id: 'high2', myr: 50, year: 2012 },
    { id: 'high3', myr: 50, year: 2013 },
    { id: 'high4', myr: 50, year: 2013 },
  ])

  strictEqual data.sum(), 200

test 'output achievement collection', ->
  Visio.manager.get('outputs').reset([
    {
      id: 'present'
      budget: 40
    },
    {
      id: 'other'
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
      id: 'high1'
      output_id: 'present'
      is_performance: true
      goal_id: 'lame'
      ppg_id: 'ben'
      myr: 50
      imp_target: 50
      reversal: false
      baseline: 20
      missing_budget: false
    },
    {
      id: 'high2'
      output_id: 'other'
      ppg_id: 'ben'
      goal_id: 'lame'
      is_performance: true
      myr: 50
      imp_target: 100
      reversal: false
      baseline: 25
      missing_budget: false
    },
    {
      id: 'low1'
      output_id: 'other'
      goal_id: 'lame'
      ppg_id: 'ben'
      is_performance: true
      imp_target: 100
      myr: 25
      reversal: false
      baseline: 25
      missing_budget: false
    },
    {
      id: 'low2'
      output_id: 'other'
      goal_id: 'lamed'
      ppg_id: 'chen'
      is_performance: true
      imp_target: 100
      myr: 25
      reversal: false
      baseline: 25
      missing_budget: false
    }

  ])

  result = data.outputAchievement()

  strictEqual result.total, 3
  strictEqual result.typeTotal, 2
  strictEqual result.counts[Visio.Algorithms.ALGO_RESULTS.high], 1
  strictEqual result.counts[Visio.Algorithms.ALGO_RESULTS.medium], 1
  strictEqual result.counts[Visio.Algorithms.ALGO_RESULTS.low], 1
  strictEqual result.category, Visio.Algorithms.ALGO_RESULTS.high

  data.get('high1').set 'myr', null
  result = data.outputAchievement()
  strictEqual result.typeTotal, 2
  strictEqual result.counts[Visio.Algorithms.STATUS.missing], 1
  strictEqual result.counts[Visio.Algorithms.ALGO_RESULTS.medium], 1
  strictEqual result.counts[Visio.Algorithms.ALGO_RESULTS.low], 1
  strictEqual result.category, Visio.Algorithms.ALGO_RESULTS.medium


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
      imp_target: 50
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
      imp_target: 100
      standard: 20
      reversal: false
      baseline: 25
      missing_budget: false
    },
    {
      id: 'jeff'
      output_id: 'present'
      problem_objective_id: 'present'
      is_performance: true
      imp_target: 100
      standard: 20
      reversal: false
      baseline: 25
      missing_budget: false
    }

  ])

  result = data.achievement()

  strictEqual .75, result.result
  strictEqual Visio.Algorithms.ALGO_RESULTS.high, result.category
  strictEqual result.total, 3
  strictEqual result.counts[Visio.Algorithms.STATUS.missing], 1
  strictEqual result.counts[Visio.Algorithms.ALGO_RESULTS.high], 2, 'Should have 2 high'

  data.get('ben').set({
    baseline: 100
    imp_target: 100
    is_performance: false
  })

  result = data.achievement()
  strictEqual(Visio.Algorithms.ALGO_RESULTS.low, result.category)

  Visio.manager.set 'achievement_type', Visio.Algorithms.GOAL_TYPES.standard
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

  empty = new Visio.Collections.IndicatorDatum()
  result = empty.achievement()
  ok not result.category
  ok not result.result

  Visio.manager.set 'reported_type', Visio.Algorithms.REPORTED_VALUES.yer
  result = data.achievement()
  strictEqual result.counts[Visio.Algorithms.STATUS.missing], 3

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
    imp_target: 50
    reversal: true
    baseline: 20
    missing_budget: false
  })

  strictEqual 1, datum.achievement().result
  strictEqual datum.achievement().category, Visio.Algorithms.ALGO_RESULTS.high

  datum.set('imp_target', 40)
  strictEqual(1, datum.achievement().result)
  strictEqual datum.achievement().category, Visio.Algorithms.ALGO_RESULTS.high

  datum.set('is_performance', false)
  strictEqual(0, datum.achievement().result)
  strictEqual datum.achievement().category, Visio.Algorithms.ALGO_RESULTS.low

  datum.set('baseline', 100)
  datum.set('imp_target', 50)
  strictEqual(1 , datum.achievement().result)
  strictEqual datum.achievement().category, Visio.Algorithms.ALGO_RESULTS.high

  datum.set('imp_target', 25)
  strictEqual(50/75 , datum.achievement().result)
  strictEqual datum.achievement().category, Visio.Algorithms.ALGO_RESULTS.high

  datum.set('reversal', false)
  datum.set('baseline', 50)
  datum.set('myr', 50)
  datum.set('imp_target', 50)

  strictEqual(1, datum.achievement().result)

  datum.set 'imp_target', 100

  strictEqual 0, datum.achievement().result

  datum.set 'missing_budget', true
  result = datum.achievement()
  strictEqual result.include, false
  strictEqual result.result, null
  strictEqual result.status, null
  strictEqual result.category, null

  datum.set 'missing_budget', false
  datum.set 'myr', null

  result = datum.achievement()
  strictEqual result.include, true
  strictEqual result.status, Visio.Algorithms.STATUS.missing
  strictEqual result.result, null
  strictEqual result.category, null

  datum.set 'reversal', true
  datum.set 'myr', 50
  datum.set 'imp_target', 100

  result = datum.achievement()
  strictEqual result.include, true
  strictEqual result.status, Visio.Algorithms.STATUS.reported
  strictEqual result.result, 1
  strictEqual result.category, Visio.Algorithms.ALGO_RESULTS.high

  Visio.manager.set 'reported_type', 'yer'
  datum.set 'reversal', false
  datum.set 'yer', 100
  datum.set 'baseline', 25
  datum.set 'imp_target', 125

  result = datum.achievement()
  strictEqual result.include, true
  strictEqual result.status, Visio.Algorithms.STATUS.reported
  strictEqual result.result, .75
  strictEqual result.category, Visio.Algorithms.ALGO_RESULTS.medium
  Visio.manager.set 'reported_type', 'myr'

  datum.set 'reversal', false
  datum.set 'myr', 50
  datum.set 'imp_target', 25
  datum.set 'is_performance', false

  result = datum.achievement()
  strictEqual result.include, true
  strictEqual result.status, Visio.Algorithms.STATUS.reported
  strictEqual result.result, 1

  datum.set 'baseline', null
  datum.set 'myr', 0

  result = datum.achievement()
  strictEqual result.include, true
  strictEqual result.status, Visio.Algorithms.STATUS.reported
  strictEqual result.result, 0

  datum.set 'imp_target', 0
  datum.set 'myr', 10
  datum.set 'is_performance', true

  result = datum.achievement()
  strictEqual result.include, true
  strictEqual result.status, Visio.Algorithms.STATUS.reported
  strictEqual result.result, 1

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
  strictEqual res.category, Visio.Algorithms.ALGO_RESULTS.ok
  strictEqual res.status, Visio.Algorithms.STATUS.reported
  strictEqual res.include, true

  datum.set 'myr', 60
  res = datum.situationAnalysis()
  strictEqual res.category, Visio.Algorithms.ALGO_RESULTS.success
  strictEqual res.status, Visio.Algorithms.STATUS.reported
  strictEqual res.include, true

  datum.set 'myr', 30
  res = datum.situationAnalysis()
  strictEqual res.category, Visio.Algorithms.ALGO_RESULTS.fail
  strictEqual res.status, Visio.Algorithms.STATUS.reported
  strictEqual res.include, true

  datum.set 'is_performance', true
  res = datum.situationAnalysis()
  strictEqual res.include, false
  strictEqual res.category, null
  strictEqual res.status, null

  datum.set 'is_performance', false
  datum.set 'myr', null
  res = datum.situationAnalysis()
  strictEqual res.include, true
  strictEqual res.category, null
  strictEqual res.status, Visio.Algorithms.STATUS.missing


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

  data = new Visio.Collections.IndicatorDatum({ id: 1, is_performance: false })
  res = data.situationAnalysis()
  strictEqual res.category, Visio.Algorithms.ALGO_RESULTS.fail
  strictEqual res.result, 0
  strictEqual res.total, 1
  strictEqual res.counts[Visio.Algorithms.STATUS.missing], 1




test 'consistent', () ->
  datum = new Visio.Models.IndicatorDatum({
    baseline: 0
    myr: 10
    yer: 20
  })

  ok datum.consistent(datum).isConsistent, 'Should be consistent'
  strictEqual datum.consistent(datum).inconsistencies.length, 0

  datum.set 'baseline', 20
  ok !datum.consistent(datum).isConsistent, 'Should not be consistent'
  ok datum.consistent(datum).inconsistencies.length, 1

  datum.set 'baseline', 21
  ok !datum.consistent(datum).isConsistent, 'Should not be consistent'
  ok datum.consistent(datum).inconsistencies.length, 2

  datum.set 'baseline', 0
  datum.set 'yer', 5
  ok !datum.consistent(datum).isConsistent, 'Should not be consistent'
  ok datum.consistent(datum).inconsistencies.length, 1

  datum.set 'yer', null
  ok datum.consistent(datum).isConsistent, 'Should be consistent'

test 'isConsistent - reversed', ->
  datum = new Visio.Models.IndicatorDatum({
    baseline: 0
    myr: 10
    yer: 5
    reversal: true
  })

  ok !datum.consistent(datum).isConsistent, 'Should not be consistent'
  strictEqual datum.consistent(datum).inconsistencies.length, 2

  datum.set 'baseline', 20
  ok datum.consistent(datum).isConsistent, 'Should be consistent'
  strictEqual datum.consistent(datum).inconsistencies.length, 0

  datum.set 'baseline', 10
  datum.set 'myr', 2
  datum.set 'yer', 5
  ok !datum.consistent(datum).isConsistent, 'Should not be consistent'
  strictEqual datum.consistent(datum).inconsistencies.length, 1

  datum.set 'yer', null
  ok datum.consistent(datum).isConsistent, 'Should be consistent'
  strictEqual datum.consistent(datum).inconsistencies.length, 0
