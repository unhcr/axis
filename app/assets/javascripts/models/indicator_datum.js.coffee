class Visio.Models.IndicatorDatum extends Backbone.Model

  constructor: () ->
    Backbone.Model.apply(@, arguments)

  urlRoot: '/indicator_data'

  paramRoot: 'indicator_datum'

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

    return Visio.Algorithms.ALGO_RESULTS.missing if @get(reported_value) == undefined || @get('comp_target') == undefined || @get('missing_budget')

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


