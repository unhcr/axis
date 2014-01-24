class Visio.Collections.CostType extends Visio.Collections.Syncable

  amount: () ->
    total = 0
    @each (cost) ->
      total += cost.amount()
    total



