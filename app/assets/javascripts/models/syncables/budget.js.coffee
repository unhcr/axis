class Visio.Models.Budget extends Visio.Models.Syncable

  urlRoot: '/budgets'

  paramRoot: 'budget'

  name: Visio.Syncables.BUDGETS.plural

  budget: () ->
    if Visio.manager.get('scenario_type')[@get('scenario')] &&
        Visio.manager.get('budget_type')[@get('budget_type')]

       return @get('amount')
    return 0
