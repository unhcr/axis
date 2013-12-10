class Visio.Models.Budget extends Visio.Models.Parameter

  urlRoot: '/budgets'

  paramRoot: 'budget'

  name: Visio.Parameters.BUDGETS

  budget: () ->
    if Visio.manager.get('scenario_type')[@get('scenario')] &&
        Visio.manager.get('budget_type')[@get('budget_type')]

       return @get('amount')
    return 0
