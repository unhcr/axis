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

  onChangePlan: (e) ->
    plan = @collection.get($(e.currentTarget).val())
    console.log plan.budget()

    @updateSituationAnalysis(plan)

    @updateMeter(Math.random())

  updateMeter: (percent) ->
    @$el.find('.meter > span').attr('style', "width: #{percent * 100}%")

  updateSituationAnalysis: (plan) ->
    data = Visio.manager.get('indicator_data').where({ plan_id: plan.id })
    counts = {}
    counts[Visio.Algorithms.ALGO_COLORS.success] = 0
    counts[Visio.Algorithms.ALGO_COLORS.ok] = 0
    counts[Visio.Algorithms.ALGO_COLORS.fail] = 0

    _.each(data, (d) ->
      counts[d.situation_analysis()] += 1
    )

    @$el.find('.' + Visio.Algorithms.ALGO_COLORS.success).text(counts[Visio.Algorithms.ALGO_COLORS.success])
    @$el.find('.' + Visio.Algorithms.ALGO_COLORS.ok).text(counts[Visio.Algorithms.ALGO_COLORS.ok])
    @$el.find('.' + Visio.Algorithms.ALGO_COLORS.fail).text(counts[Visio.Algorithms.ALGO_COLORS.fail])


