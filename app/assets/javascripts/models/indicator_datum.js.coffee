class Visio.Models.IndicatorDatum extends Backbone.Model

  constructor: () ->
    Backbone.Model.apply(@, arguments)

  urlRoot: '/indicator_data'

  paramRoot: 'indicator_datum'

  missingBudget: () ->
    if @get('is_performance')
      output = Visio.manager.get('outputs').findWhere({ id: @get('output_id') })
      return true if !output || (output.get('budget') == 0 || !output.get('budget'))
    else
      problem_objective = Visio.manager.get('problem_objectives').findWhere(
        id: @get('problem_objective_id'))
      return true if !problem_objective ||
        (problem_objective.get('budget') == 0 || !problem_objective.get('budget'))

    return false
  situation_analysis: (reported_value) ->
    reported_value ||= Visio.Algorithms.REPORTED_VALUES.myr
    return Visio.Algorithms.ALGO_RESULTS.missing unless @get(reported_value)

    if @get(reported_value) >= @get('threshold_green')
      return Visio.Algorithms.ALGO_RESULTS.success
    else if @get(reported_value) >= @get('threshold_red')
      return Visio.Algorithms.ALGO_RESULTS.ok
    else
      return Visio.Algorithms.ALGO_RESULTS.fail

  achievement: (reported_value) ->

    reported_value ||= Visio.Algorithms.REPORTED_VALUES.myr

    return Visio.Algorithms.ALGO_RESULTS.missing if @get(reported_value) == undefined || @get('comp_target') == undefined || @missingBudget()

    if @get('is_performance')
      result = +@get(reported_value) / +@get('comp_target')
      return Math.min(result, 1)

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


