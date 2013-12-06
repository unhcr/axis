module 'Parameter',

  setup: () ->
    Visio.manager = new Visio.Models.Manager()


test 'selectedIndicatorData', () ->
  selected = Visio.manager.get('selected')

  _.each Visio.manager.get('types'), (type) ->
    selected[type] = [1]


  _.each Visio.manager.get('types'), (type) ->
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

  _.each Visio.manager.get('types'), (type) ->
    selected = Visio.manager.selected(type)
    strictEqual(selected.length, 1)

    selected.each (d) ->
      data = d.selectedIndicatorData()

      strictEqual(data.length, 1)
      ok(data instanceof Visio.Collections.IndicatorDatum)
      ok(data.get('blue'))

test 'selectedStrategyData', () ->
  strategy = { id: 17 }


  _.each Visio.manager.get('types'), (type) ->
    strategy["#{type}_ids"] = [1]


  Visio.manager.get('strategies').reset([strategy])
  Visio.manager.set('strategy_id', Visio.manager.get('strategies').at(0).id)

  _.each Visio.manager.get('types'), (type) ->
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

  _.each Visio.manager.get('types'), (type) ->
    selected = Visio.manager.strategy().get("#{type}_ids")
    strictEqual(selected.length, 1)

    _.each selected, (id) ->
      model = Visio.manager.get(type).get(id)
      data = model.strategyIndicatorData()

      strictEqual(data.length, 1)
      ok(data instanceof Visio.Collections.IndicatorDatum)
      ok(data.get('blue'))