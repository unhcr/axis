class Visio.Views.AchievementBudgetSingleYearView extends Backbone.View

  template: JST['modules/achievement_budget_single_year']

  initialize: (options) ->

  render: (isRerender) ->

    if !isRerender
      @$el.html @template()
      options =
        width: 600
        height: 400
        selection: d3.select('#bubble')

      @bubble = Visio.Graphs.bubble(options)

    @bubble.parameters(Visio.manager.selected(Visio.Parameters.PLANS).models)
    @bubble()

    @
