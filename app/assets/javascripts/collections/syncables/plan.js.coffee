class Visio.Collections.Plan extends Visio.Collections.Syncable

  model: Visio.Models.Plan

  name: Visio.Syncables.PLANS

  url: '/plans'

  getPlansForDifferentYear: (year) ->
    newPlans = new Visio.Collections.Plan()
    @each (plan) ->
      newPlan = plan.getPlanForDifferentYear year
      newPlans.add newPlan if newPlan

    newPlans
