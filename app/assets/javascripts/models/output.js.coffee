class Visio.Models.Output extends Visio.Models.Parameter

  constructor: () ->
    Backbone.Model.apply(@, arguments)

  urlRoot: '/outputs'

  paramRoot: 'output'

  name: Visio.Parameters.OUTPUTS

  budget: () ->
    total = 0
    for scenario, sActivated of Visio.manager.get('scenario_type')
      for budget, bActivated of Visio.manager.get('budget_type')
        if sActivated && bActivated
          total += @get("#{scenario}_#{budget}_budget") || 0

    total
