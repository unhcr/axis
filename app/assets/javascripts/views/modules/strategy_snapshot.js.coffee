class Visio.Views.StrategySnapshotView extends Backbone.View

  template: JST['modules/strategy_snapshot']

  initialize: (options) ->
    @collection = Visio.manager.targetPlans()
    @model = @collection.at(0)

  events:
    'change .ui-blank-radio > input': 'onChangePlan'

  render: (isRerender) ->

    if !isRerender
      @$el.html @template(
        targetPlans: @collection.toJSON()
      )

    @updateSituationAnalysis(@model)

    @updateMeter(Math.random())

  onChangePlan: (e) ->
    @model = @collection.get($(e.currentTarget).val())
    console.log @model.strategyBudget()
    @render(true)


  updateMeter: (percent) ->
    @$el.find('.meter > span').attr('style', "width: #{percent * 100}%")

  updateSituationAnalysis: (plan) ->
    data = Visio.manager.get('indicator_data').where({ plan_id: plan.id })
    counts = {}
    counts[Visio.Algorithms.ALGO_RESULTS.success] = 0
    counts[Visio.Algorithms.ALGO_RESULTS.ok] = 0
    counts[Visio.Algorithms.ALGO_RESULTS.fail] = 0

    _.each(data, (d) ->
      counts[d.situation_analysis()] += 1
    )

    @$el.find('.' + Visio.Algorithms.ALGO_RESULTS.success).text(counts[Visio.Algorithms.ALGO_RESULTS.success])
    @$el.find('.' + Visio.Algorithms.ALGO_RESULTS.ok).text(counts[Visio.Algorithms.ALGO_RESULTS.ok])
    @$el.find('.' + Visio.Algorithms.ALGO_RESULTS.fail).text(counts[Visio.Algorithms.ALGO_RESULTS.fail])


