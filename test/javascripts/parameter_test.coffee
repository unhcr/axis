module 'Parameter',

  setup: () ->
    Visio.manager = new Visio.Models.Manager()

test 'strategyBudgetData', () ->
  strategy = { id: 17 }


  _.each Visio.Types, (type) ->
    strategy["#{type}_ids"] = {}
    strategy["#{type}_ids"]['1'] = true


  Visio.manager.get('strategies').reset([strategy])
  Visio.manager.set('strategy_id', Visio.manager.get('strategies').at(0).id)

  _.each Visio.Types, (type) ->
    Visio.manager.get(type).reset([
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

  _.each Visio.Types, (type) ->
    selected = Visio.manager.strategy().get("#{type}_ids")
    strictEqual(_.keys(selected).length, 1)

    _.each _.keys(selected), (id) ->
      model = Visio.manager.get(type).get(id)
      data = model.strategyBudgetData()

      if type != Visio.Parameters.OUTPUTS
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

  _.each Visio.Types, (type) ->
    selected[type] = {}
    selected[type]['1'] = true


  _.each Visio.Types, (type) ->
    Visio.manager.get(type).reset([
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
      output_id: undefined
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

  _.each Visio.Types, (type) ->
    selected = Visio.manager.selected(type)
    strictEqual(selected.length, 1)

    selected.each (d) ->
      data = d.selectedBudgetData()

      if type == Visio.Parameters.OUTPUTS
        strictEqual(data.length, 1)
      else
        strictEqual(data.length, 2)
        ok(data.get('green'))

      ok(data.get('blue'))
      ok(data instanceof Visio.Collections.Budget)

test 'selectedIndicatorData', () ->
  selected = Visio.manager.get('selected')

  _.each Visio.Types, (type) ->
    selected[type] = {}
    selected[type]['1'] = true


  _.each Visio.Types, (type) ->
    Visio.manager.get(type).reset([
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

  _.each Visio.Types, (type) ->
    selected = Visio.manager.selected(type)
    strictEqual(selected.length, 1)

    selected.each (d) ->
      data = d.selectedIndicatorData()

      strictEqual(data.length, 1)
      ok(data instanceof Visio.Collections.IndicatorDatum)
      ok(data.get('blue'))

test 'strategyIndicatorData', () ->
  strategy = { id: 17 }


  _.each Visio.Types, (type) ->
    strategy["#{type}_ids"] = {}
    strategy["#{type}_ids"]['1'] = true


  Visio.manager.get('strategies').reset([strategy])
  Visio.manager.set('strategy_id', Visio.manager.get('strategies').at(0).id)

  _.each Visio.Types, (type) ->
    Visio.manager.get(type).reset([
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

  _.each Visio.Types, (type) ->
    selected = Visio.manager.strategy().get("#{type}_ids")
    strictEqual(_.keys(selected).length, 1)

    _.each _.keys(selected), (id) ->
      model = Visio.manager.get(type).get(id)
      data = model.strategyIndicatorData()

      strictEqual(data.length, 1)
      ok(data instanceof Visio.Collections.IndicatorDatum)
      ok(data.get('blue'))

 test 'toString', () ->
  _.each Visio.Types, (type) ->
    Visio.manager.get(type).reset([
      {
        id: 1
        name: 'ben'
        operation_name: 'lisa'
        objective_name: 'george'
      }
    ])

  _.each Visio.Types, (type) ->
    parameters = Visio.manager.get(type)

    p = parameters.at(0)

    if type == Visio.Parameters.PLANS
      strictEqual p.toString(), 'lisa'
    else if type == Visio.Parameters.PPGS
      strictEqual p.toString(), '[lisa] ben'
    else if type == Visio.Parameters.PROBLEM_OBJECTIVES
      strictEqual p.toString(), 'george'
    else
      strictEqual p.toString(), 'ben'


