class Visio.Collections.Budget extends Visio.Collections.Parameter

  model: Visio.Models.Budget

  name: Visio.Parameters.BUDGETS

  url: '/budgets'

  budget: () ->
    total = 0
    @each (b) ->
      total += b.budget()
    total

