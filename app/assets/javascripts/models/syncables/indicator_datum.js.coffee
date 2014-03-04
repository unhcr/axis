class Visio.Models.IndicatorDatum extends Visio.Models.Syncable

  urlRoot: '/indicator_data'

  paramRoot: 'indicator_datum'

  operation: -> @getParameter(Visio.Parameters.OPERATIONS)
  ppg: -> @getParameter(Visio.Parameters.PPGS)
  goal: -> @getParameter(Visio.Parameters.GOALS)
  indicator: -> @getParameter(Visio.Parameters.INDICATORS)
  output: -> @getParameter(Visio.Parameters.OUTPUTS)
  problem_objective: -> @getParameter(Visio.Parameters.PROBLEM_OBJECTIVES)

  getParameter: (parameterHash) ->
    id = @get "#{parameterHash.singular}_id"
    Visio.manager.get(parameterHash.plural).get(id)

  isConsistent: ->
    baseline = @get Visio.Algorithms.REPORTED_VALUES.baseline
    myr = @get Visio.Algorithms.REPORTED_VALUES.myr
    yer = @get Visio.Algorithms.REPORTED_VALUES.yer

    return myr >= baseline and
      (yer >= myr or not _.isNumber(yer))


  situationAnalysis: (reported) ->
    result =
      status: null
      category: null
      include: null

    result.include = not @get 'is_performance'

    return result unless result.include

    reported ||= Visio.manager.get('reported_type')

    if @get(reported)?
      result.status = Visio.Algorithms.STATUS.reported
    else
      result.status = Visio.Algorithms.STATUS.missing

    return result unless result.status == Visio.Algorithms.STATUS.reported

    if @get(reported) >= @get('threshold_green')
      result.category = Visio.Algorithms.ALGO_RESULTS.success
    else if @get(reported) >= @get('threshold_red')
      result.category = Visio.Algorithms.ALGO_RESULTS.ok
    else
      result.category = Visio.Algorithms.ALGO_RESULTS.fail

    result

  achievement: (reported) ->

    result =
      status: null
      result: null
      include: null

    reported ||= Visio.manager.get('reported_type')
    achievement_type = Visio.manager.get('achievement_type')

    # Exclude if no budget
    result.include = not @get('missing_budget')

    return result unless result.include

    if @get(reported)? and @get(achievement_type)?
      result.status = Visio.Algorithms.STATUS.reported
    else
      result.status = Visio.Algorithms.STATUS.missing

    return result unless result.status == Visio.Algorithms.STATUS.reported


    if @get('is_performance')
      result.result = Math.min(+@get(reported) / +@get(achievement_type), 1)
      result.result = 1 if isNaN result.result
    else
      if @get(reported) == @get(achievement_type)
        result.result = 1
        return result

      if @get('reversal')
        # Reverse indicator
        if @get(reported) > @get(achievement_type)
          if +@get('baseline') <= @get(reported)
            result.result = 0
            return result

          numerator = @get('baseline') - @get(reported)
          denominator = @get('baseline') - @get(achievement_type)

          result.result =  numerator / denominator

        else
          result.result = 1

      else
        # Normal indicator
        if @get(reported) < @get(achievement_type)

          if +@get('baseline') >= @get(reported)
            result.result = 0
            return result

          numerator = @get(reported) - @get('baseline')
          denominator = @get(achievement_type) - @get('baseline')

          result.result = numerator / denominator
        else

          result.result = 1

    if isNaN(result.result)
      console.log result

    return result
