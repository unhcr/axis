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

    # Note: none will be selected for Indicators if type is Budget or Expenditure
    models = [
      # Should always be selected except when aggr by Output
      {
        id: 'green'
        operation_id: 1
        ppg_id: 1
        goal_id: 1
        problem_objective_id: 1
        output_id: null
        ol_admin_budget: 100
        strategy_objective_ids: [1]
        year: 2012
      },
      # Should never be selected since SO is not selected
      {
        id: 'orange'
        operation_id: 1
        ppg_id: 1
        goal_id: 1
        problem_objective_id: 1
        output_id: null
        ol_admin_budget: 100
        strategy_objective_ids: [2]
        year: 2012
      },
      # Should always be selected
      {
        id: 'blue'
        operation_id: 1
        ppg_id: 1
        goal_id: 1
        output_id: 1
        problem_objective_id: 1
        ol_admin_budget: 100
        strategy_objective_ids: [1, 2]
        year: 2012
      },
      # Should never be selected since ppg is not selected
      {
        id: 'red'
        operation_id: 1
        ppg_id: 2
        goal_id: 1
        output_id: 1
        problem_objective_id: 1
        ol_admin_budget: 100
        strategy_objective_ids: [1]
        year: 2012
      },
      # Should only be selected with allYears flag present
      {
        id: 'yellow'
        operation_id: 1
        ppg_id: 1
        goal_id: 1
        output_id: 1
        problem_objective_id: 1
        ol_admin_budget: 100
        strategy_objective_ids: [1]
        year: 2013
      }]
    Visio.manager.get('expenditures').reset(models)

    Visio.manager.get('budgets').reset(models)

    _.each models, (model) -> model.indicator_id = 1
    Visio.manager.get('indicator_data').reset(models)

test 'strategyExpenditureData', () ->
  nParams = _.values(Visio.Parameters).length

  _.each _.values(Visio.Parameters), (hash) ->
    selected = Visio.manager.strategy().get("#{hash.singular}_ids")
    selectedArr = _.keys selected

    strictEqual(selectedArr.length, 1)

    _.each selectedArr, (id) ->
      model = Visio.manager.get(hash.plural).get(id)
      data = model.strategyExpenditureData()

      if hash == Visio.Parameters.OUTPUTS
        len = 2
        ok data.get('blue'), "Should always have blue #{hash.human}"
      else if hash == Visio.Parameters.INDICATORS
        len = 0
      else
        len = 3
        ok data.get('green'), "Should always have green for #{hash.human}"
        ok data.get('blue'), "Should always have blue #{hash.human}"


      ok data instanceof Visio.Collections.Expenditure, 'Should be an Expenditure collection'



test 'selectedExpenditureData', () ->

  _.each _.values(Visio.Parameters), (hash) ->
    selected = Visio.manager.selected(hash.plural)
    strictEqual selected.length, 1, "There should be 1 #{hash.human} selected"

    selected.each (d) ->
      data = d.selectedExpenditureData()

      if hash == Visio.Parameters.OUTPUTS
        len = 2
        ok data.get('blue'), "Should always have blue #{hash.human}"
      else if hash == Visio.Parameters.INDICATORS
        len = 0
      else
        len = 3
        ok data.get('green'), "Should always have green for #{hash.human}"
        ok data.get('blue'), "Should always have blue #{hash.human}"

      ok(data instanceof Visio.Collections.Expenditure)

test 'strategyBudgetData', () ->

  _.each _.values(Visio.Parameters), (hash) ->
    selected = Visio.manager.strategy().get("#{hash.singular}_ids")
    selectedArr = _.keys selected

    strictEqual(selectedArr.length, 1)

    _.each selectedArr, (id) ->
      model = Visio.manager.get(hash.plural).get(id)
      data = model.strategyBudgetData()

      if hash.plural == Visio.Parameters.OUTPUTS.plural
        len = 1
        ok data.get 'blue'
      else if hash.plural == Visio.Parameters.INDICATORS.plural
        len = 0
      else
        len = 2
        ok data.get('green'), "Should always have green for #{hash.human}"
        ok data.get('blue'), "Should always have blue #{hash.human}"

      ok(data instanceof Visio.Collections.Budget)
      strictEqual data.length, len, "There should be #{len} when aggr by #{hash.human}"


test 'selectedBudgetData - allYears', () ->
  _.each _.values(Visio.Parameters), (hash) ->
    selected = Visio.manager.selected(hash.plural)
    strictEqual selected.length, 1, "There should be 1 #{hash.human} selected"

    selected.each (d) ->
      data = d.selectedBudgetData(true)

      if hash == Visio.Parameters.OUTPUTS
        len = 2
        ok data.get('blue'), "Should always have blue #{hash.human}"
      else if hash == Visio.Parameters.INDICATORS
        len = 0
      else
        len = 3
        ok data.get('green'), "Should always have green for #{hash.human}"
        ok data.get('blue'), "Should always have blue #{hash.human}"

      ok(data instanceof Visio.Collections.Budget)
      strictEqual data.length, len, "There should be #{len} when aggr by #{hash.human}"

test 'selectedBudgetData', () ->

  _.each _.values(Visio.Parameters), (hash) ->
    selected = Visio.manager.selected(hash.plural)
    strictEqual selected.length, 1, "There should be 1 #{hash.human} selected"

    selected.each (d) ->
      data = d.selectedBudgetData()

      ok data instanceof Visio.Collections.Budget
      if hash.plural == Visio.Parameters.OUTPUTS.plural
        len = 1
        ok data.get 'blue'
      else if hash.plural == Visio.Parameters.INDICATORS.plural
        len = 0
      else
        len = 2
        ok data.get('green'), "Should always have green for #{hash.human}"
        ok data.get('blue'), "Should always have blue #{hash.human}"

      strictEqual data.length, len, "There should be #{len} when aggr by #{hash.human}"

test 'selectedIndicatorData', () ->

  _.each _.values(Visio.Parameters), (hash) ->
    selected = Visio.manager.selected(hash.plural)
    strictEqual(selected.length, 1)

    selected.each (d) ->
      data = d.selectedIndicatorData()

      ok data instanceof Visio.Collections.IndicatorDatum
      if hash.plural == Visio.Parameters.OUTPUTS.plural
        len = 1
        ok data.get 'blue'
      else
        len = 2
        ok data.get('green'), "Should always have green for #{hash.human}"
        ok data.get('blue'), "Should always have blue #{hash.human}"

      strictEqual data.length, len, "There should be #{len} when aggr by #{hash.human}"

test 'strategyIndicatorData', () ->

  _.each _.values(Visio.Parameters), (hash) ->
    selected = Visio.manager.strategy().get("#{hash.singular}_ids")
    strictEqual(_.keys(selected).length, 1)

    _.each _.keys(selected), (id) ->
      model = Visio.manager.get(hash.plural).get(id)
      data = model.strategyIndicatorData()

      ok data instanceof Visio.Collections.IndicatorDatum
      if hash.plural == Visio.Parameters.OUTPUTS.plural
        len = 1
        ok data.get 'blue'
      else
        len = 2
        ok data.get('green'), "Should always have green for #{hash.human}"
        ok data.get('blue'), "Should always have blue #{hash.human}"

      strictEqual data.length, len, "There should be #{len} when aggr by #{hash.human}"

test 'toString', () ->
  values = _.values(Visio.Parameters)
  values.push Visio.Syncables.PLANS
  _.each values, (hash) ->
    Visio.manager.get(hash.plural).reset([
      {
        id: 1
        name: 'ben'
        operation_name: 'lisa'
        objective_name: 'george'
      }
    ])


  _.each values, (hash) ->
    parameters = Visio.manager.get(hash.plural)

    p = parameters.at(0)

    if hash.plural == Visio.Syncables.PLANS.plural
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
