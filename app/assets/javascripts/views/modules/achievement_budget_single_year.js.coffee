class Visio.Views.AchievementBudgetSingleYearView extends Backbone.View

  template: JST['modules/achievement_budget_single_year']

  className: 'module'

  events:
    'click .scenario .visio-check input': 'onClickScenario'
    'click .budget .visio-check input': 'onClickBudget'
    'change .achievement-type-toggle': 'onAchievementTypeChange'

  initialize: (options) ->

  render: (isRerender) ->

    if !isRerender
      @$el.html @template()
      config =
        width: @$el.find('#bubble').width()
        height: 320
        selection: d3.select(@el).select('#bubble')
        margin:
          top: 10
          bottom: 30
          left: 90
          right: 80

      @bubble = Visio.Graphs.bubble(config)

    _.each _.keys(Visio.manager.get('scenario_type')), (scenario) =>
      @$el.find("input[value='#{scenario}']").prop('checked', true)

    _.each _.keys(Visio.manager.get('budget_type')), (budget) =>
      @$el.find("input[value='#{budget}']").prop('checked', true)

    @bubble.parameters(Visio.manager.selected(Visio.manager.get('aggregation_type')).models)
    @bubble()

    @

  onAchievementTypeChange: (e) =>
    if Visio.manager.get('achievement_type') == Visio.AchievementTypes.TARGET
      achievement_type = Visio.AchievementTypes.STANDARD
    else
      achievement_type = Visio.AchievementTypes.TARGET

    Visio.manager.set 'achievement_type', achievement_type

  onClickScenario: (e) =>
    $target = $(e.currentTarget)

    if $target.is(':checked')
      Visio.manager.get('scenario_type')[$target.val()] = true
    else
      delete Visio.manager.get('scenario_type')[$target.val()]

    @render(true)

  onClickBudget: (e) =>
    $target = $(e.currentTarget)

    if $target.is(':checked')
      Visio.manager.get('budget_type')[$target.val()] = true
    else
      delete Visio.manager.get('budget_type')[$target.val()]

    @render(true)
