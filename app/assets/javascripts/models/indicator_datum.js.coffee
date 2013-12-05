class Visio.Models.IndicatorDatum extends Backbone.Model

  constructor: () ->
    Backbone.Model.apply(@, arguments)

  urlRoot: '/indicator_data'

  paramRoot: 'indicator_datum'

  missingBudget: () ->
    if @get('is_performance')
      output = Visio.manager.get('outputs').findWhere({ id: @get('output_id') })
      return true if !output || (output.get('ol_budget') == 0 || !output.get('ol_budget'))
    else
      problem_objective = Visio.manager.get('problem_objectives').findWhere(
        id: @get('problem_objective_id'))
      return true if !problem_objective ||
        (problem_objective.get('ol_budget') == 0 || !problem_objective.get('ol_budget'))

    return false

  achievement: (reported_value) ->

    reported_value ||= Visio.Algorithms.REPORTED_VALUES.myr

    return Visio.Algorithms.ALGO_RESULTS.missing if !@get(reported_value) || !@get('comp_target') || @missingBudget()

    if @get('is_performance')
      result = +@get(reported_value) / +@get('comp_target')
      return Math.max(result, 1)

    else
      return 1 if @get(reported_value) == @get('comp_target')

      if @get('reversal')
        # Reverse indicator
        if @get(reported_value) > @get('comp_target')
          return 0 if @get('baseline') <= @get(reported_value)

          return (@get('baseline') - @get(reported_value)) / (@get('baseline') - @get('comp_target'))
        else
          return 1

      else
        # Normal indicator
        if @get(reported_value) < @get('comp_target')

          return 0 if @get('baseline') >= @get(reported_value)

          return (@get(reported_value) - @get('baseline')) / (@get('comp_target') - @get('baseline'))
        else

          return 1


