class Visio.Collections.Plan extends Visio.Collections.Parameter

  model: Visio.Models.Plan

  name: Visio.Parameters.PLANS.plural

  url: '/plans'

  getPlansForDifferentYear: (year) ->
    newPlans = new Visio.Collections.Plan()
    @each (plan) ->
      newPlan = plan.getPlanForDifferentYear year
      newPlans.add newPlan if newPlan

    newPlans
