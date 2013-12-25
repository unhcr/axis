class Visio.Models.IndicatorDatum extends Visio.Models.Syncable

  urlRoot: '/indicator_data'

  paramRoot: 'indicator_datum'

  situationAnalysis: (reported) ->
    reported ||= Visio.Algorithms.REPORTED_VALUES.myr
    return Visio.Algorithms.ALGO_RESULTS.missing unless @get(reported)

    if @get(reported) >= @get('threshold_green')
      return Visio.Algorithms.ALGO_RESULTS.success
    else if @get(reported) >= @get('threshold_red')
      return Visio.Algorithms.ALGO_RESULTS.ok
    else
      return Visio.Algorithms.ALGO_RESULTS.fail

  achievement: (reported) ->

    reported ||= Visio.Algorithms.REPORTED_VALUES.myr
    achievement_type = Visio.manager.get('achievement_type')

    return Visio.Algorithms.ALGO_RESULTS.missing if @get(reported) == undefined || @get(achievement_type) == undefined || @get('missing_budget') || @get('missing_budget') == undefined

    if @get('is_performance')
      result = +@get(reported) / +@get(achievement_type)
      return Math.min(result, 1)

    else
      return 1 if @get(reported) == @get(achievement_type)

      if @get('reversal')
        # Reverse indicator
        if @get(reported) > @get(achievement_type)
          return 0 if @get('baseline') <= @get(reported)

          return (@get('baseline') - @get(reported)) / (@get('baseline') - @get(achievement_type))
        else
          return 1

      else
        # Normal indicator
        if @get(reported) < @get(achievement_type)

          return 0 if @get('baseline') >= @get(reported)

          return (@get(reported) - @get('baseline')) / (@get(achievement_type) - @get('baseline'))
        else

          return 1


