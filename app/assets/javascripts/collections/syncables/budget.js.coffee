class Visio.Collections.Budget extends Visio.Collections.Syncable

  model: Visio.Models.Budget

  name: Visio.Syncables.BUDGETS.plural

  url: '/budgets'

  budget: () ->
    total = 0
    @each (b) ->
      total += b.budget()
    total

