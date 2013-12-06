class Visio.Views.StrategySnapshotView extends Backbone.View

  template: JST['modules/strategy_snapshot']

  initialize: (options) ->
    @collection = Visio.manager.targetPlans()

  events:
    'change .ui-blank-radio > input': 'onChangePlan'

  render: () ->

    @$el.html @template(
      targetPlans: @collection.toJSON()
    )

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
    @$el.find('.expenditure').text "#{d3.round(percent * 100)}%"
    @$el.find('.budget').text "$#{Visio.Formats.SI(budget)}"
    @$el.find('.meter > span').attr('style', "width: #{percent * 100}%")

  updateSituationAnalysis: (plan) ->
    counts = {}
    counts[Visio.Algorithms.ALGO_RESULTS.success] = 0
    counts[Visio.Algorithms.ALGO_RESULTS.ok] = 0
    counts[Visio.Algorithms.ALGO_RESULTS.fail] = 0
    if plan
      data = Visio.manager.get('indicator_data').where({ plan_id: plan.id })

      _.each(data, (d) ->
        counts[d.situation_analysis()] += 1
      )
    else
      # calc for whole strategy

