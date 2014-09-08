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

  consistencyFnList: [
    'myrGreaterThanBaseline',
    'yerGreaterThanBaseline',
    'yerGreaterThanMyr',
    'targetGreaterThanBaseline']

  myrGreaterThanBaseline: =>
    inconsistency = 'MYR is less than baseline'
    baseline = @get Visio.Algorithms.REPORTED_VALUES.baseline
    myr = @get Visio.Algorithms.REPORTED_VALUES.myr

    if @get 'reversal'
      return inconsistency if myr >= baseline and _.isNumber(myr)
    else
      return inconsistency if myr < baseline and _.isNumber(myr)
    null

  yerGreaterThanBaseline: =>
    inconsistency = 'YER is less than baseline'
    baseline = @get Visio.Algorithms.REPORTED_VALUES.baseline
    yer = @get Visio.Algorithms.REPORTED_VALUES.yer

    if @get 'reversal'
      return inconsistency if yer >= baseline and _.isNumber(yer)
    else
      return inconsistency if yer < baseline and _.isNumber(yer)
    null

  yerGreaterThanMyr: =>
    inconsistency = 'YER is less than MYR'
    myr = @get Visio.Algorithms.REPORTED_VALUES.myr
    yer = @get Visio.Algorithms.REPORTED_VALUES.yer

    if @get 'reversal'
      return inconsistency if yer >= myr and _.isNumber(yer) and _.isNumber(myr)
    else
      return inconsistency if yer < myr and _.isNumber(yer) and _.isNumber(myr)
    null

  targetGreaterThanBaseline: =>
    inconsistency = 'Impact target is less than basline'
    impTarget = @get Visio.Algorithms.GOAL_TYPES.imp_target
    baseline = @get Visio.Algorithms.REPORTED_VALUES.baseline

    if @get 'reversal'
      return inconsistency if impTarget >= baseline
    else
      return inconsistency if impTarget < baseline
    null


  consistent: ->

    result =
      inconsistencies: []
      isConsistent: true

    _.each @consistencyFnList, (consistencyFn) =>
      inconsistency = @[consistencyFn]()
      if inconsistency?
        result.isConsistent = false
        result.inconsistencies.push inconsistency

    result

  isPercentage: ->
    @get('indicator_type') == Visio.IndicatorTypes.PERCENTAGE

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
      category: null

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
      else if @get('reversal')
        # Reverse indicator
        if @get(reported) > @get(achievement_type)
          if +@get('baseline') <= @get(reported)
            result.result = 0
          else
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
          else
            numerator = @get(reported) - @get('baseline')
            denominator = @get(achievement_type) - @get('baseline')

            result.result = numerator / denominator
        else

          result.result = 1

    if isNaN(result.result)
      console.log result

    divisor = if reported == Visio.Algorithms.REPORTED_VALUES.yer then 1 else 2

    if result.result >= Visio.Algorithms.HIGH_THRESHOLD / divisor
      result.category = Visio.Algorithms.ALGO_RESULTS.high
    else if result.result >= Visio.Algorithms.MEDIUM_THRESHOLD / divisor
      result.category = Visio.Algorithms.ALGO_RESULTS.medium
    else
      result.category = Visio.Algorithms.ALGO_RESULTS.low

    return result
