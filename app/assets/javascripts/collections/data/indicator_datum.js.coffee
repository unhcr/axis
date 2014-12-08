class Visio.Collections.IndicatorDatum extends Visio.Collections.Data

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
    reported ||= Visio.manager.get 'reported_type'
    results = []

    counts = {}
    counts[Visio.Algorithms.ALGO_RESULTS.high] = 0
    counts[Visio.Algorithms.ALGO_RESULTS.medium] = 0
    counts[Visio.Algorithms.ALGO_RESULTS.low] = 0
    counts[Visio.Algorithms.STATUS.missing] = 0
    return { category: null, result: null, counts: counts, total: 0 } if @length == 0

    groups = @groupBy (d) -> "#{d.get('ppg_id')}#{d.get('goal_id')}#{d.get('output_id')}"

    for name, group of groups
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

    total = counts[Visio.Algorithms.ALGO_RESULTS.high] +
            counts[Visio.Algorithms.ALGO_RESULTS.medium] +
            counts[Visio.Algorithms.ALGO_RESULTS.low] +
            counts[Visio.Algorithms.STATUS.missing]

    typeTotal = _.uniq(@pluck('output_id')).length

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

  sum: (reported) ->
    reported ||= Visio.manager.get 'reported_type'

    @reduce ((sum, model) -> sum + model.get(reported)), 0

  achievement: (reported) ->
    reported ||= Visio.manager.get 'reported_type'
    results = []

    counts = {}
    counts[Visio.Algorithms.ALGO_RESULTS.high] = 0
    counts[Visio.Algorithms.ALGO_RESULTS.medium] = 0
    counts[Visio.Algorithms.ALGO_RESULTS.low] = 0
    counts[Visio.Algorithms.STATUS.missing] = 0
    return { category: null, result: null, counts: counts, total: 0 } if @length == 0

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

    if results.length == 0 and counts[Visio.Algorithms.STATUS.missing] > 0
      average = 0
      category = Visio.Algorithms.STATUS.missing
    else if average >= Visio.Algorithms.HIGH_THRESHOLD / divisor
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
