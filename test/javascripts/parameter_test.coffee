module 'Parameter',

  setup: () ->
    Visio.user = new Visio.Models.User()
    Visio.manager = new Visio.Models.Manager()
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
      # Should never be selected unless we inlcude external data
      {
        id: 'purple'
        operation_id: 1
        ppg_id: 1
        goal_id: 1
        problem_objective_id: 1
        output_id: null
        ol_admin_budget: 100
        strategy_objective_ids: []
        year: 2012
      }
      # Should never be selected unless we include external data
      {
        id: 'pink'
        operation_id: 1
        ppg_id: 1
        goal_id: 1
        output_id: null
        problem_objective_id: 1
        ol_admin_budget: 100
        strategy_objective_ids: [3]
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

    populations = [
      # golden
      {
        element_type: 'goals'
        element_id: 1
        ppg_id: 1
        value: 2
        year: 2012
      },
      # wrong type
      {
        element_type: 'ppgs'
        element_id: 1
        ppg_id: 1
        value: 3
        year: 2012
      },
      # wrong ppg_id
      {
        element_type: 'goals'
        element_id: 1
        ppg_id: 2
        value: 1
        year: 2012
      }
      # wrong year
      {
        element_type: 'goals'
        element_id: 1
        ppg_id: 1
        value: 3
        year: 2014
      },
    ]
    Visio.manager.get('expenditures').reset(models)

    Visio.manager.get('budgets').reset(models)

    _.each models, (model) -> model.indicator_id = 1
    Visio.manager.get('indicator_data').reset(models)
    Visio.manager.get('populations').reset(populations)
test 'selectedPopulation', ->
  g = Visio.manager.get('goals').get(1)

  res = g.selectedPopulation()
  strictEqual res, 2

  res = g.selectedPopulation(2012)
  strictEqual res, 2

  res = g.selectedPopulation(2014)
  strictEqual res, 3

  o = Visio.manager.get('operations').get(1)

  res = o.selectedPopulation(2014)
  strictEqual res, 0

  p = Visio.manager.get('ppgs').get(1)

  res = p.selectedPopulation()
  strictEqual res, 3


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
      data = d.selectedBudgetData(Visio.Constants.ANY_YEAR)

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

test 'selectedIndicatorData - external data', ->
  Visio.manager.includeExternalStrategyData true
  Visio.manager.select Visio.Parameters.STRATEGY_OBJECTIVES.plural,
    Visio.Constants.ANY_STRATEGY_OBJECTIVE

  _.each _.values(Visio.Parameters), (hash) ->
    selected = Visio.manager.selected(hash.plural)

    if hash == Visio.Parameters.STRATEGY_OBJECTIVES
      strictEqual selected.length, 2, 'Should have two SOs'
    else
      strictEqual selected.length, 1

    selected.each (d) ->
      data = d.selectedIndicatorData()

      ok data instanceof Visio.Collections.IndicatorDatum
      if hash.plural == Visio.Parameters.OUTPUTS.plural
        len = 1
        ok data.get 'blue'
      else if hash.plural == Visio.Parameters.STRATEGY_OBJECTIVES.plural and d.id == Visio.Constants.ANY_STRATEGY_OBJECTIVE
        len = 2

        # SOs are ignored so should be selected
        ok data.get('purple'), "Should always have purple #{hash.human}"
        ok data.get('pink'), "Should always have pink #{hash.human}"
      else if hash.plural == Visio.Parameters.STRATEGY_OBJECTIVES.plural and d.id != Visio.Constants.ANY_STRATEGY_OBJECTIVE
        len = 2
        ok data.get('green'), "Should always have green for #{hash.human}"
        ok data.get('blue'), "Should always have blue #{hash.human}"
      else
        len = 4
        ok data.get('green'), "Should always have green for #{hash.human}"
        ok data.get('blue'), "Should always have blue #{hash.human}"

        # SOs are ignored so should be selected
        ok data.get('purple'), "Should always have purple #{hash.human}"
        ok data.get('pink'), "Should always have pink #{hash.human}"

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
      strictEqual p.toString(), 'LISA: ben'
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

test 'search', ->

  sinon.stub $, 'get', (query) ->
    dfd = new $.Deferred()
    dfd.resolve [{ id: 'b' }, { id: 'a' }, { id: 'c' }]
    return dfd.promise()

  _.each _.values(Visio.Parameters), (hash, i) ->
    collection = new Visio.Collections[hash.className]()
    model = new Visio.Models[hash.className]()

    collection.search('something').done (resp) ->
      strictEqual resp.length, 3
      strictEqual $.get.callCount, 2 * i + 1

    model.search('something').done (resp) ->
      strictEqual resp.length, 3
      strictEqual $.get.callCount, 2 * i + 2

  $.get.restore()

test 'include', ->

  operation = new Visio.Models.Operation
    ppg_ids: {'abc': true, 'efg': true}

  ok operation.include('ppg', 'abc'), 'Should include that ppg'
  ok operation.include('operation', operation.id), 'Should include its own'

  ok not operation.include('ppg', 'no'), 'Should not include not found'
  ok not operation.include('weird', 'no'), 'Should not include not found'
