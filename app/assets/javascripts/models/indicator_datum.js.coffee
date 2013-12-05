class Visio.Models.IndicatorDatum extends Backbone.Model

  constructor: () ->
    Backbone.Model.apply(@, arguments)

  urlRoot: '/indicator_data'

  paramRoot: 'indicator_datum'

  achievement: (reported_value) ->

    reported_value ||= Visio.Algorithms.REPORTED_VALUES.myr

    return Visio.Algorithms.ALGO_RESULTS.missing if !@get(reported_value) || !@get('comp_target')

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


