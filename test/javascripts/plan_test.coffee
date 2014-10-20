module 'Plan',
  setup: () ->
    Visio.user = new Visio.Models.User()
    Visio.manager = new Visio.Models.Manager()
    Visio.manager.set 'reported_type', Visio.Algorithms.REPORTED_VALUES.myr

  teardown: () ->
    Visio.manager.get('db').clear()

test 'strategy situation analysis', () ->
  p = new Visio.Models.Plan({ operation_id: 'op', id: 'abcd', name: 'ben', situation_analysis:
    {
      category: Visio.Algorithms.ALGO_RESULTS.success
      result: 1
    }
  })
  Visio.manager.get('indicator_data').reset([
    {
      id: 1
      yer: 20
      myr: 8
      threshold_green: 10
      threshold_red: 5
      operation_id: 1
      plan_id: 1
      goal_id: 1
      output_id: 1
      ppg_id: 1
      problem_objective_id: 1
      indicator_id: 1
      strategy_objective_ids: [1]
      is_performance: false
    },
    {
      id: 2
      yer: 30
      myr: 21
      threshold_green: 40
      threshold_red: 20
      operation_id: 2
      plan_id: 2
      goal_id: 2
      output_id: 2
      ppg_id: 2
      problem_objective_id: 2
      indicator_id: 2
      strategy_objective_ids: [2]
      is_performance: false
    }])

  sinon.stub p, 'strategyData', -> new Visio.Collections.IndicatorDatum()

  result = p.strategySituationAnalysis()
  strictEqual(Visio.Algorithms.ALGO_RESULTS.success, result.category)
  strictEqual p.strategyData.callCount, 0

  Visio.manager.get('strategies').reset [{ id: 1 }, { id: 2, }]

  Visio.manager.get('selected_strategies')['1'] = true
  Visio.manager.get('selected_strategies')['2'] = true

  p.strategyData.restore()
  sinon.stub p, 'strategyData', -> Visio.manager.get('indicator_data')

  result = p.strategySituationAnalysis()
  strictEqual Visio.Algorithms.ALGO_RESULTS.ok, result.category
  strictEqual p.strategyData.callCount, 2

  delete Visio.manager.get('selected_strategies')['2']

  p.strategyData.restore()
  sinon.stub p, 'strategyData', -> new Visio.Collections.IndicatorDatum(Visio.manager.get('indicator_data').get(1))

  result = p.strategySituationAnalysis()
  strictEqual(Visio.Algorithms.ALGO_RESULTS.ok, result.category)
  strictEqual p.strategyData.callCount, 1
  p.strategyData.restore()
