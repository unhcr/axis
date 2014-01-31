module 'Parameter',

  setup: () ->
    Visio.user = new Visio.Models.User()
    Visio.manager = new Visio.Models.Manager()
    Visio.manager.set 'use_cache', false
    Visio.manager.year(2012)
    strategy = { id: 17 }
    _.each _.values(Visio.Parameters), (hash) =>
      strategy["#{hash.singular}_ids"] = {}
      strategy["#{hash.singular}_ids"]['1'] = true

    Visio.manager.get('strategies').reset([strategy])
    Visio.manager.set('strategy_id', Visio.manager.get('strategies').at(0).id)

    selected = Visio.manager.get('selected')

    _.each _.values(Visio.Parameters), (hash) ->
      selected[hash.plural] = {}
      selected[hash.plural]['1'] = true

    _.each _.values(Visio.Parameters), (hash) ->
      models = [{ id: 1 }, { id: 2 }]
      if hash == Visio.Parameters.STRATEGY_OBJECTIVES
        models[0].strategy_id = strategy.id
      Visio.manager.get(hash.plural).reset(models)

    Visio.manager.get('expenditures').reset([
      {
        id: 'green'
        plan_id: 1
        ppg_id: 1
        goal_id: 1
        problem_objective_id: 1
        output_id: null
        ol_admin_budget: 100
        strategy_objective_ids: [2]
        year: 2012
      },
      {
        id: 'blue'
        plan_id: 1
        ppg_id: 1
        goal_id: 1
        output_id: 1
        problem_objective_id: 1
        ol_admin_budget: 100
        strategy_objective_ids: [1, 2]
        year: 2012
      },
      {
        id: 'red'
        plan_id: 2
        ppg_id: 1
        goal_id: 1
        output_id: 1
        problem_objective_id: 1
        ol_admin_budget: 100
        strategy_objective_ids: [1]
        year: 2012
      },
    ])

    Visio.manager.get('budgets').reset([
      {
        id: 'green'
        plan_id: 1
        ppg_id: 1
        goal_id: 1
        problem_objective_id: 1
        output_id: null
        ol_admin_budget: 100
        strategy_objective_ids: [2]
        year: 2012
      },
      {
        id: 'blue'
        plan_id: 1
        ppg_id: 1
        goal_id: 1
        output_id: 1
        problem_objective_id: 1
        ol_admin_budget: 100
        strategy_objective_ids: [1, 2]
        year: 2012
      },
      {
        id: 'red'
        plan_id: 2
        ppg_id: 1
        goal_id: 1
        output_id: 1
        problem_objective_id: 1
        ol_admin_budget: 100
        strategy_objective_ids: [1]
        year: 2012
      },
    ])

    Visio.manager.get('indicator_data').reset([

      {
        id: 'blue'
        plan_id: 1
        ppg_id: 1
        goal_id: 1
        output_id: 1
        problem_objective_id: 1
        indicator_id: 1
        strategy_objective_ids: [1]
        year: 2012
      },
      {
        id: 'red'
        plan_id: 2
        ppg_id: 1
        goal_id: 2
        output_id: 1
        problem_objective_id: 2
        indicator_id: 1
        strategy_objective_ids: [2]
        year: 2012
      },
      {
        id: 'purple'
        plan_id: 3
        ppg_id: 1
        goal_id: 2
        output_id: 1
        problem_objective_id: 2
        indicator_id: 1
        strategy_objective_ids: [1]
        year: 2014
      }
    ])

test 'strategyExpenditureData', () ->
  nParams = _.values(Visio.Parameters).length
  expect((4 * (nParams- 1) + 3 + nParams ))

  _.each _.values(Visio.Parameters), (hash) ->
    selected = Visio.manager.strategy().get("#{hash.singular}_ids")
    selectedArr = _.keys selected

    strictEqual(selectedArr.length, 1)

    _.each selectedArr, (id) ->
      model = Visio.manager.get(hash.plural).get(id)
      data = model.strategyExpenditureData()

      if hash.plural != Visio.Parameters.OUTPUTS.plural
        strictEqual(data.length, 2)
        ok(data instanceof Visio.Collections.Expenditure)
        ok(data.get('blue'))
        foundId = if hash == Visio.Parameters.STRATEGY_OBJECTIVES then 'red' else 'green'
        ok(data.get(foundId))
      else
        strictEqual(data.length, 1)
        ok(data instanceof Visio.Collections.Expenditure)
        ok(data.get('blue'))



test 'selectedExpenditureData', () ->

  _.each _.values(Visio.Parameters), (hash) ->
    selected = Visio.manager.selected(hash.plural)
    strictEqual selected.length, 1, "There should be 1 #{hash.human} selected"

    selected.each (d) ->
      data = d.selectedExpenditureData()

      if hash.plural == Visio.Parameters.OUTPUTS.plural
        strictEqual data.length, 1, 'There should 1 be output'
      else
        strictEqual data.length, 2, "There should 2 be #{hash.human}"
        foundId = if hash == Visio.Parameters.STRATEGY_OBJECTIVES then 'red' else 'green'
        ok(data.get(foundId))

      ok(data.get('blue'))
      ok(data instanceof Visio.Collections.Expenditure)

test 'strategyBudgetData', () ->

  _.each _.values(Visio.Parameters), (hash) ->
    selected = Visio.manager.strategy().get("#{hash.singular}_ids")
    selectedArr = _.keys selected

    strictEqual(selectedArr.length, 1)

    _.each selectedArr, (id) ->
      model = Visio.manager.get(hash.plural).get(id)
      data = model.strategyBudgetData()

      if hash.plural != Visio.Parameters.OUTPUTS.plural
        strictEqual(data.length, 2)
        ok(data instanceof Visio.Collections.Budget)
        ok(data.get('blue'))
        foundId = if hash == Visio.Parameters.STRATEGY_OBJECTIVES then 'red' else 'green'
        ok(data.get(foundId))
      else
        strictEqual(data.length, 1)
        ok(data instanceof Visio.Collections.Budget)
        ok(data.get('blue'))



test 'selectedBudgetData', () ->

  _.each _.values(Visio.Parameters), (hash) ->
    selected = Visio.manager.selected(hash.plural)
    strictEqual selected.length, 1, "There should be 1 #{hash.human} selected"

    selected.each (d) ->
      data = d.selectedBudgetData()

      if hash.plural == Visio.Parameters.OUTPUTS.plural
        strictEqual data.length, 1, 'There should 1 be output'
      else
        strictEqual data.length, 2, "There should 2 be #{hash.human}"
        foundId = if hash == Visio.Parameters.STRATEGY_OBJECTIVES then 'red' else 'green'
        ok(data.get(foundId))

      ok(data.get('blue'))
      ok(data instanceof Visio.Collections.Budget)

test 'selectedIndicatorData', () ->

  _.each _.values(Visio.Parameters), (hash) ->
    selected = Visio.manager.selected(hash.plural)
    strictEqual(selected.length, 1)

    selected.each (d) ->
      data = d.selectedIndicatorData()

      strictEqual(data.length, 1, "Failed length for #{hash.plural}")
      ok(data instanceof Visio.Collections.IndicatorDatum)
      ok(data.get('blue'))

  Visio.manager.get('indicator_data').get('blue').set('output_id', null)

  _.each _.values(Visio.Parameters), (hash) ->
    selected = Visio.manager.selected(hash.plural)
    strictEqual(selected.length, 1)

    selected.each (d) ->
      data = d.selectedIndicatorData()

      if hash.plural == Visio.Parameters.OUTPUTS.plural
        strictEqual(data.length, 0)
        ok(data instanceof Visio.Collections.IndicatorDatum)
      else
        strictEqual(data.length, 1, "Failed length for #{hash.plural}")
        ok(data instanceof Visio.Collections.IndicatorDatum)
        ok(data.get('blue'))

test 'strategyIndicatorData', () ->

  _.each _.values(Visio.Parameters), (hash) ->
    selected = Visio.manager.strategy().get("#{hash.singular}_ids")
    strictEqual(_.keys(selected).length, 1)

    _.each _.keys(selected), (id) ->
      model = Visio.manager.get(hash.plural).get(id)
      data = model.strategyIndicatorData()

      strictEqual(data.length, 1, "Failed length for #{hash.plural}")
      ok(data instanceof Visio.Collections.IndicatorDatum)
      ok(data.get('blue'))

test 'toString', () ->
  _.each _.values(Visio.Parameters), (hash) ->
    Visio.manager.get(hash.plural).reset([
      {
        id: 1
        name: 'ben'
        operation_name: 'lisa'
        objective_name: 'george'
      }
    ])

  _.each _.values(Visio.Parameters), (hash) ->
    parameters = Visio.manager.get(hash.plural)

    p = parameters.at(0)

    if hash.plural == Visio.Parameters.PLANS.plural
      strictEqual p.toString(), 'lisa'
    else if hash.plural == Visio.Parameters.PPGS.plural
      strictEqual p.toString(), '[lisa] ben'
    else if hash.plural == Visio.Parameters.PROBLEM_OBJECTIVES.plural
      strictEqual p.toString(), 'george'
    else
      strictEqual p.toString(), 'ben'

test 'refId', ->
  _.each _.values(Visio.Parameters), (hash) ->
    model = Visio.manager.get(hash.plural).at(0)

    if hash == Visio.Parameters.PLANS
      model.set('operation_id', 2)
      strictEqual model.get('operation_id'), model.refId()
    else
      strictEqual model.id, model.refId()

test 'caching', ->
  Visio.manager.set 'use_cache', true
  keys = [
    'strategyExpenditure',
    'strategyBudget',
    'strategySituationAnalysis',
    'selectedAchievement',
    'selectedBudget',
    'selectedSituationAnalysis',
    'selectedExpenditure'
  ]

  data =
    'Budget': new Visio.Collections.Budget([])
    'Indicator': new Visio.Collections.IndicatorDatum([])
    'Expenditure': new Visio.Collections.Expenditure([])
  parameter = Visio.manager.get(Visio.Parameters.OUTPUTS.plural).at(0)

  _.each ['Budget', 'Indicator', 'Expenditure'], (dataType) ->
    switch dataType
      when 'Budget', 'Expenditure'
        sinon.stub data[dataType], 'amount', () -> 10
      when 'Indicator'
        sinon.stub data[dataType], 'achievement', () -> 10
        sinon.stub data[dataType], 'situationAnalysis', () -> 10

    _.each ['selected', 'strategy'], (selectorType) ->
      sinon.stub parameter,  selectorType + dataType + 'Data', () ->
        return data[dataType]


  _.each keys, (key) ->
    result = parameter[key]()
    strictEqual result, 10, 'Initially shouldnot use cache'

  _.each ['Budget', 'Indicator', 'Expenditure'], (dataType) ->
    switch dataType
      when 'Budget', 'Expenditure'
        data[dataType].amount.restore()
        sinon.stub data[dataType], 'amount', () -> 20
      when 'Indicator'
        data[dataType].achievement.restore()
        data[dataType].situationAnalysis.restore()
        sinon.stub data[dataType], 'achievement', () -> 20
        sinon.stub data[dataType], 'situationAnalysis', () -> 20

  _.each keys, (key) ->
    result = parameter[key]()
    strictEqual result, 10, 'Should use cache for: ' + key

  Visio.manager.set 'bust_cache', true
  _.each keys, (key) ->
    result = parameter[key]()
    strictEqual result, 20, 'When bust_cache is set, do not use cache'
