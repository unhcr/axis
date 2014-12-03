class Visio.Collections.AmountType extends Visio.Collections.Data

  amount: () ->
    total = 0
    @each (cost) ->
      total += cost.amount()
    total



