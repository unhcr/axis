class Visio.Views.StrategySnapshotView extends Backbone.View

  template: JST['modules/strategy_snapshot']

  resultTypes: [
    Visio.Algorithms.ALGO_RESULTS.success,
    Visio.Algorithms.ALGO_RESULTS.ok,
    Visio.Algorithms.ALGO_RESULTS.fail,
    Visio.Algorithms.ALGO_RESULTS.missing,
  ]

  initialize: (options) ->
    @collection = Visio.manager.targetPlans()

  events:
    'change .ui-blank-radio > input': 'onChangePlan'

  render: () ->

    @$el.html @template(
      targetPlans: @collection.toJSON()
      resultTypes: @resultTypes
    )
    @countCircles = []
    _.each @resultTypes, (resultType) =>
      config =
        resultType: resultType
        width: 120
        height: 120
        selection: d3.select(".#{resultType}-circle")
        percent: Math.random()
        number: 45
        margin:
          top: 20
          bottom: 20
          left: 20
          right: 20

      @countCircles.push
        circle: Visio.Graphs.circle(config)
        type: resultType

    _.each @countCircles, (circle) ->
      circle.circle()


  update: () =>
    @updateSituationAnalysis(@model)

    if @model
      budget = @model.strategyBudget()
    else
      budget = @collection.reduce(
        (budget, p) -> return budget + p.strategyBudget(),
        0)

    @updateMeter(Math.random(), budget)


  onChangePlan: (e) ->
    id = $(e.currentTarget).val()

    if id == 'all'
      @model = null
    else
      @model = @collection.get(id)

    @update()

  updateMeter: (percent, budget) ->
    console.log budget
    $expenditure = @$el.find('.expenditure span')
    $budget = @$el.find('.budget')

    $expenditure.countTo(
      from: +$expenditure.text()
      to: d3.round(percent * 100)
      speed: Visio.Durations.FAST
    )
    @$el.find('.budget').text "$#{Visio.Formats.SI(budget)}"
    @$el.find('.meter > span').attr('style', "width: #{percent * 100}%")

  updateSituationAnalysis: (plan) =>
    counts = {}
    _.each @resultTypes, (resultType) ->
      counts[resultType] = 0

    if plan
      data = Visio.manager.get('indicator_data').where({ plan_id: plan.id })

      _.each(data, (d) ->
        counts[d.situation_analysis()] += 1
      )

      for resultType, count of counts
        circle = _.findWhere @countCircles, { type: resultType }
        circle.circle
          .number(count)
          .percent(count / data.length)()

      $totalIndicators = @$el.find('.total-indicators')

      $totalIndicators.countTo(
        from: +$totalIndicators.text()
        to: data.length
        speed: Visio.Durations.FAST
      )



    else
      # calc for whole strategy

