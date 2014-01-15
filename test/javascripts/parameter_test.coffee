module 'Parameter',

  setup: () ->
    Visio.user = new Visio.Models.User()
    Visio.manager = new Visio.Models.Manager()

test 'strategyBudgetData', () ->
  strategy = { id: 17 }


  _.each _.values(Visio.Parameters), (hash) ->
    strategy["#{hash.singular}_ids"] = {}
    strategy["#{hash.singular}_ids"]['1'] = true


  Visio.manager.get('strategies').reset([strategy])
  Visio.manager.set('strategy_id', Visio.manager.get('strategies').at(0).id)

  _.each _.values(Visio.Parameters), (hash) ->
    Visio.manager.get(hash.plural).reset([
      {
        id: 1
      },
      {
        id: 2
      }
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
    },
    {
      id: 'blue'
      plan_id: 1
      ppg_id: 1
      goal_id: 1
      output_id: 1
      problem_objective_id: 1
      ol_admin_budget: 100
    },
    {
      id: 'red'
      plan_id: 2
      ppg_id: 1
      goal_id: 1
      output_id: 1
      problem_objective_id: 1
      ol_admin_budget: 100
    }
  ])

  _.each _.values(Visio.Parameters), (hash) ->
    selected = Visio.manager.strategy().get("#{hash.singular}_ids")
    strictEqual(_.keys(selected).length, 1)

    _.each _.keys(selected), (id) ->
      model = Visio.manager.get(hash.plural).get(id)
      data = model.strategyBudgetData()

      if hash.plural != Visio.Parameters.OUTPUTS.plural
        strictEqual(data.length, 2)
        ok(data instanceof Visio.Collections.Budget)
        ok(data.get('blue'))
        ok(data.get('green'))
      else
        strictEqual(data.length, 1)
        ok(data instanceof Visio.Collections.Budget)
        ok(data.get('blue'))



test 'selectedBudgetData', () ->
  selected = Visio.manager.get('selected')

  _.each _.values(Visio.Parameters), (hash) ->
    selected[hash.plural] = {}
    selected[hash.plural]['1'] = true


  _.each _.values(Visio.Parameters), (hash) ->
    Visio.manager.get(hash.plural).reset([
      {
        id: 1
      },
      {
        id: 2
      }
    ])

  Visio.manager.get('budgets').reset([

    {
      id: 'blue'
      scenario: 'Above Operating Level'
      budget_type: 'ADMIN'
      amount: 100
      plan_id: 1
      ppg_id: 1
      goal_id: 1
      output_id: 1
      problem_objective_id: 1
    },
    {
      id: 'green'
      scenario: 'Above Operating Level'
      budget_type: 'ADMIN'
      amount: 500
      plan_id: 1
      ppg_id: 1
      goal_id: 1
      output_id: null
      problem_objective_id: 1
    },
    {
      id: 'red'
      scenario: 'Above Operating Level'
      budget_type: 'ADMIN'
      amount: 200
      plan_id: 2
      ppg_id: 1
      goal_id: 2
      problem_objective_id: 2
    }
  ])

  _.each _.values(Visio.Parameters), (hash) ->
    selected = Visio.manager.selected(hash.plural)
    strictEqual(selected.length, 1)

    selected.each (d) ->
      data = d.selectedBudgetData()

      if hash.plural == Visio.Parameters.OUTPUTS.plural
        strictEqual(data.length, 1)
      else
        strictEqual(data.length, 2)
        ok(data.get('green'))

      ok(data.get('blue'))
      ok(data instanceof Visio.Collections.Budget)

test 'selectedIndicatorData', () ->
  selected = Visio.manager.get('selected')

  _.each _.values(Visio.Parameters), (hash) ->
    selected[hash.plural] = {}
    selected[hash.plural]['1'] = true


  _.each _.values(Visio.Parameters), (hash) ->
    Visio.manager.get(hash.plural).reset([
      {
        id: 1
      },
      {
        id: 2
      }
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
    },
    {
      id: 'red'
      plan_id: 2
      ppg_id: 1
      goal_id: 2
      output_id: 1
      problem_objective_id: 2
      indicator_id: 1
    }
  ])

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
  strategy = { id: 17 }


  _.each _.values(Visio.Parameters), (hash) ->
    strategy["#{hash.singular}_ids"] = {}
    strategy["#{hash.singular}_ids"]['1'] = true


  Visio.manager.get('strategies').reset([strategy])
  Visio.manager.set('strategy_id', Visio.manager.get('strategies').at(0).id)

  _.each _.values(Visio.Parameters), (hash) ->
    Visio.manager.get(hash.plural).reset([
      {
        id: 1
      },
      {
        id: 2
      }
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
    },
    {
      id: 'red'
      plan_id: 2
      ppg_id: 1
      goal_id: 2
      output_id: 1
      problem_objective_id: 2
      indicator_id: 1
    }
  ])

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


