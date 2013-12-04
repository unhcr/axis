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

    @updateMeter(Math.random())

  updateMeter: (percent) ->
    @$el.find('.meter > span').attr('style', "width: #{percent * 100}%")
