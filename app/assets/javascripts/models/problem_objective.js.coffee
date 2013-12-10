class Visio.Models.ProblemObjective extends Visio.Models.Parameter

  constructor: () ->
    Backbone.Model.apply(@, arguments)

  urlRoot: '/problem_objectives'

  paramRoot: 'problem_objective'

  toString: () ->
    return @get('objective_name')

  name: Visio.Parameters.PROBLEM_OBJECTIVES

  # Gets budget for problem obj
  budget: () ->
    total = 0
    for scenerio, sActivated of Visio.manager.get('scenerio_type')
      for budget, bActivated of Visio.manager.get('budget_type')
        if sActivated && bActivated
          total += @get("#{scenerio}_#{budget}_budget") || 0

    total


