class Visio.Collections.IndicatorDatum extends Visio.Collections.Syncable

  model: Visio.Models.IndicatorDatum

  name: Visio.Syncables.INDICATOR_DATA

  url: '/indicator_data'

  situationAnalysis: (reported) ->

    reported or= Visio.manager.get 'reported_type'

    counts = {}
    counts[Visio.Algorithms.ALGO_RESULTS.success] = 0
    counts[Visio.Algorithms.ALGO_RESULTS.ok] = 0
    counts[Visio.Algorithms.ALGO_RESULTS.fail] = 0
    counts[Visio.Algorithms.STATUS.missing] = 0
    types = {}

    @each((datum) ->
      result = datum.situationAnalysis()

      types[datum.get('indicator_id')] = true if result.include

      if result.include and result.status == Visio.Algorithms.STATUS.reported
        counts[result.category] += 1
      else if result.include and result.status == Visio.Algorithms.STATUS.missing
        counts[result.status] += 1
    )

    typeTotal = _.keys(types).length
    count = counts[Visio.Algorithms.ALGO_RESULTS.success] +
            counts[Visio.Algorithms.ALGO_RESULTS.ok] +
            counts[Visio.Algorithms.ALGO_RESULTS.fail] +
            counts[Visio.Algorithms.STATUS.missing]

    result = (counts[Visio.Algorithms.ALGO_RESULTS.success] / count) +
             (0.5 * (counts[Visio.Algorithms.ALGO_RESULTS.ok] / count))


    if result >= Visio.Algorithms.SUCCESS_THRESHOLD
      category = Visio.Algorithms.ALGO_RESULTS.success
    else if result >= Visio.Algorithms.OK_THRESHOLD
      category = Visio.Algorithms.ALGO_RESULTS.ok
    else
      category = Visio.Algorithms.ALGO_RESULTS.fail

    result = if isNaN(result) then 0 else result
    return {
      result: result
      category: category
      counts: counts
      total: count
      typeTotal: typeTotal
    }

  outputAchievement: (reported) ->
    return { category: null, result: null } if @length == 0
    reported ||= Visio.manager.get 'reported_type'
    results = []

    counts = {}
    counts[Visio.Algorithms.ALGO_RESULTS.high] = 0
    counts[Visio.Algorithms.ALGO_RESULTS.medium] = 0
    counts[Visio.Algorithms.ALGO_RESULTS.low] = 0
    counts[Visio.Algorithms.STATUS.missing] = 0

    groups = @groupBy 'output_id'

    _.each groups, (group) ->
      cGroup = new Visio.Collections.IndicatorDatum group
      result = cGroup.achievement()

      # Push result if there are some data that was recorded
      if result.total and (result.counts[Visio.Algorithms.ALGO_RESULTS.high] or
                           result.counts[Visio.Algorithms.ALGO_RESULTS.medium] or
                           result.counts[Visio.Algorithms.ALGO_RESULTS.low])
        results.push result.result
        counts[result.category] += 1
      else if result.total and result.counts[Visio.Algorithms.STATUS.missing]
        counts[Visio.Algorithms.STATUS.missing] += 1

    typeTotal = counts[Visio.Algorithms.ALGO_RESULTS.high] +
            counts[Visio.Algorithms.ALGO_RESULTS.medium] +
            counts[Visio.Algorithms.ALGO_RESULTS.low] +
            counts[Visio.Algorithms.STATUS.missing]

    total = @where({ missing_budget: false }).length

    average = _.reduce(results,
      (sum, num) -> return sum + num,
      0) / results.length

    divisor = if reported == Visio.Algorithms.REPORTED_VALUES.yer then 1 else 2

    if average >= Visio.Algorithms.HIGH_THRESHOLD / divisor
      category = Visio.Algorithms.ALGO_RESULTS.high
    else if average >= Visio.Algorithms.MEDIUM_THRESHOLD / divisor
      category = Visio.Algorithms.ALGO_RESULTS.medium
    else
      category = Visio.Algorithms.ALGO_RESULTS.low

    result =
      counts: counts
      total: total
      typeTotal: typeTotal
      category: category
      result: average

    result


  achievement: (reported) ->
    return { category: null, result: null } if @length == 0
    reported ||= Visio.manager.get 'reported_type'
    results = []

    counts = {}
    counts[Visio.Algorithms.ALGO_RESULTS.high] = 0
    counts[Visio.Algorithms.ALGO_RESULTS.medium] = 0
    counts[Visio.Algorithms.ALGO_RESULTS.low] = 0
    counts[Visio.Algorithms.STATUS.missing] = 0

    types = {}

    @each (datum) ->
      result = datum.achievement(reported)

      types[datum.get('indicator_id')] = true if result.include

      if result.include and result.status == Visio.Algorithms.STATUS.reported
        results.push(result.result)
        counts[result.category] += 1
      else if result.include and result.status == Visio.Algorithms.STATUS.missing
        counts[result.status] += 1

    count = counts[Visio.Algorithms.ALGO_RESULTS.high] +
            counts[Visio.Algorithms.ALGO_RESULTS.medium] +
            counts[Visio.Algorithms.ALGO_RESULTS.low] +
            counts[Visio.Algorithms.STATUS.missing]

    average = _.reduce(results,
      (sum, num) -> return sum + num,
      0) / results.length

    typeTotal = _.keys(types).length

    divisor = if reported == Visio.Algorithms.REPORTED_VALUES.yer then 1 else 2

    if average >= Visio.Algorithms.HIGH_THRESHOLD / divisor
      category = Visio.Algorithms.ALGO_RESULTS.high
    else if average >= Visio.Algorithms.MEDIUM_THRESHOLD / divisor
      category = Visio.Algorithms.ALGO_RESULTS.medium
    else
      category = Visio.Algorithms.ALGO_RESULTS.low

    result =
      category: category
      result: average
      counts: counts
      total: count
      typeTotal: typeTotal


    result
