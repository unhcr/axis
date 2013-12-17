class Visio.Views.StrategySnapshotView extends Backbone.View

  template: JST['modules/strategy_snapshot']

  maxListLength: 10

  resultTypes: [
    Visio.Algorithms.ALGO_RESULTS.success,
    Visio.Algorithms.ALGO_RESULTS.ok,
    Visio.Algorithms.ALGO_RESULTS.fail,
    Visio.Algorithms.ALGO_RESULTS.missing,
  ]

  initialize: (options) ->
    @collection = Visio.manager.strategy().plans()

  events:
    'change .ui-blank-radio > input': 'onChangePlan'
    'click .js-show-all': 'onClickShowAll'

  render: () ->

    @$el.html @template(
      targetPlans: @collection.where({ year: Visio.manager.year() }).map (plan) -> plan.toJSON()
      resultTypes: @resultTypes
      max: @maxListLength
      cols: 3
    )
    @countCircles = []
    _.each @resultTypes, (resultType) =>
      config =
        resultType: resultType
        width: 85
        height: 85
        selection: d3.select(".#{resultType}-circle")
        percent: Math.random()
        number: 45
        margin:
          top: 10
          bottom: 10
          left: 0
          right: 10

      @countCircles.push
        circle: Visio.Graphs.circle(config)
        type: resultType

    @update()

  update: () =>
    @updateSituationAnalysis(@model)

    if @model
      budget = @model.strategyBudget()
      @$el.find('.js-operation-name').text @model.get('operation_name')
    else
      budget = @collection.where({ year: Visio.manager.year() }).reduce(
        (budget, p) -> return budget + p.strategyBudget(),
        0)
      @$el.find('.js-operation-name').text 'All Target Countries'

    @updateMeter(Math.random(), budget)

  onClickShowAll: (e) ->
    @$el.find('.js-extra-target-countries').toggleClass 'gone'

  onChangePlan: (e) ->
    id = $(e.currentTarget).val()

    if id == 'all'
      @model = null
    else
      @model = @collection.get(id)

    @update()

  updateMeter: (percent, budget) =>
    $expenditure = @$el.find('.expenditure span')

    $expenditure.countTo(
      from: +$expenditure.text()
      to: d3.round(percent * 100)
      speed: Visio.Durations.FAST
      formatter: Visio.Utils.countToFormatter
    )
    @$el.find('.budget').text "$#{Visio.Formats.SI(budget)}"
    @$el.find('.meter > span').attr('style', "width: #{percent * 100}%")

  updateSituationAnalysis: (plan) =>

    if plan
      counts = @situationAnalysisCounts(plan)


    else
      counts = {}
      _.each @resultTypes, (resultType) ->
        counts[resultType] = 0

      _.each(@collection.where({ year: Visio.manager.year() }), (plan) =>
        result = @situationAnalysisCounts(plan)
        _.each @resultTypes, (resultType) ->
          counts[resultType] += result[resultType])

    total = 0
    for resultType, count of counts
      total += count

    _.each @resultTypes, (type) =>
      circle = _.findWhere @countCircles, { type: type }
      circle.circle
        .number(counts[type])
        .percent(counts[type] / total)()

    $totalIndicators = @$el.find('.total-indicators')

    $totalIndicators.countTo(
      from: +$totalIndicators.text()
      to: total
      speed: Visio.Durations.FAST
      formatter: Visio.Utils.countToFormatter
    )



  situationAnalysisCounts: (plan) =>
    counts = {}
    _.each @resultTypes, (resultType) ->
      counts[resultType] = 0

    data = Visio.manager.get('indicator_data').where({ plan_id: plan.id })

    _.each(data, (d) ->
      counts[d.situation_analysis()] += 1
    )

    counts
