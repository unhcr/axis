class Visio.Collections.Budget extends Visio.Collections.Parameter

  model: Visio.Models.Budget

  name: Visio.Parameters.BUDGETS

  url: '/budgets'

  budget: () ->
    total = 0
    @each (b) ->
        if Visio.manager.get('scenario_type')[b.get('scenario')] &&
           Visio.manager.get('budget_type')[b.get('budget_type')]
          total += b.get('amount')
    total

