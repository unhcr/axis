class Visio.Views.AchievementBudgetSingleYearView extends Backbone.View

  template: JST['modules/achievement_budget_single_year']

  events:
    'click .scenerio .visio-check input': 'onClickScenerio'
    'click .budget .visio-check input': 'onClickBudget'

  initialize: (options) ->

  render: (isRerender) ->

    if !isRerender
      @$el.html @template()
      options =
        width: 800
        height: 400
        selection: d3.select('#bubble')

      @bubble = Visio.Graphs.bubble(options)

    @bubble.parameters(Visio.manager.selected(Visio.manager.get('aggregation_type')).models)
    @bubble()

    @

  onClickScenerio: (e) =>
    $target = $(e.currentTarget)

    if $target.is(':checked')
      Visio.manager.get('scenerio_type')[$target.val()] = true
    else
      Visio.manager.get('scenerio_type')[$target.val()] = false

    @render(true)

  onClickBudget: (e) =>
    $target = $(e.currentTarget)

    if $target.is(':checked')
      Visio.manager.get('budget_type')[$target.val()] = true
    else
      Visio.manager.get('budget_type')[$target.val()] = false

    @render(true)
