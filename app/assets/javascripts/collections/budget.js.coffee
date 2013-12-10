class Visio.Collections.Budget extends Visio.Collections.Parameter

  model: Visio.Models.Budget

  name: Visio.Parameters.BUDGETS

  url: '/budgets'

  budget: () ->

    @reduce(
      (sum, b) ->
        if Visio.manager.get('scenario_type')[b.get('scenario')] &&
           Visio.manager.get('budget_type')[b.get('budget_type')]
          return sum + b.get('amount'),
        else
          return 0
      0)

