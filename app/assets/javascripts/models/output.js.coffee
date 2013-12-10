class Visio.Models.Output extends Visio.Models.Parameter

  constructor: () ->
    Backbone.Model.apply(@, arguments)

  urlRoot: '/outputs'

  paramRoot: 'output'

  name: Visio.Parameters.OUTPUTS

  budget: () ->
    total = 0
    for scenerio, sActivated of Visio.manager.get('scenerio_type')
      for budget, bActivated of Visio.manager.get('budget_type')
        if sActivated && bActivated
          total += @get("#{scenerio}_#{budget}_budget") || 0

    total
