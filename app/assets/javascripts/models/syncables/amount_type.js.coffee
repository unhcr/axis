class Visio.Models.AmountType extends Visio.Models.Syncable

  amount: ->
    if Visio.manager.get('scenario_type')[@get('scenario')] &&
        Visio.manager.get('budget_type')[@get('budget_type')]

       return @get('amount')
    return 0

