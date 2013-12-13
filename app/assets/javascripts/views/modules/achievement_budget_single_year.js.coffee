class Visio.Views.AchievementBudgetSingleYearView extends Backbone.View

  template: JST['modules/achievement_budget_single_year']

  events:
    'click .scenario .visio-check input': 'onClickScenario'
    'click .budget .visio-check input': 'onClickBudget'

  initialize: (options) ->

  render: (isRerender) ->

    if !isRerender
      @$el.html @template()
      config =
        width: @$el.find('#bubble').width()
        height: 400
        selection: d3.select('#bubble')
        margin:
          top: 20
          bottom: 50
          left: 90
          right: 50

      @bubble = Visio.Graphs.bubble(config)

    _.each Visio.Scenarios, (scenario) =>
      if Visio.manager.get('scenario_type')[scenario]
        @$el.find("input[value='#{scenario}']").prop('checked', true)

    _.each Visio.Budgets, (budget) =>
      if Visio.manager.get('budget_type')[budget]
        @$el.find("input[value='#{budget}']").prop('checked', true)

    @bubble.parameters(Visio.manager.selected(Visio.manager.get('aggregation_type')).models)
    @bubble()

    @

  onClickScenario: (e) =>
    $target = $(e.currentTarget)

    if $target.is(':checked')
      Visio.manager.get('scenario_type')[$target.val()] = true
    else
      Visio.manager.get('scenario_type')[$target.val()] = false

    @render(true)

  onClickBudget: (e) =>
    $target = $(e.currentTarget)

    if $target.is(':checked')
      Visio.manager.get('budget_type')[$target.val()] = true
    else
      Visio.manager.get('budget_type')[$target.val()] = false

    @render(true)
