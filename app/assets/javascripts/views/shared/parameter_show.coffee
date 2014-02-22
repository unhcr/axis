class Visio.Views.ParameterShowView extends Backbone.View

  tagName: 'article'

  className: 'parameter-show pbi-avoid'

  template: HAML['shared/parameter_show']

  initialize: (options) ->
    @idx = options.idx
    @filters = options.filters


  render: ->

    cols = []
    rows = ['dummy']

    _.each _.values(Visio.Budgets), (budgetType) =>
      cols.push budgetType if @filters.filter('budget_type', budgetType)

    _.each _.values(Visio.Scenarios), (scenario) =>
      rows.push scenario if @filters.filter('scenario', scenario)

    achievement = @model.selectedAchievement().result
    @$el.html @template({ model: @model, idx: @idx, cols: cols, rows: rows })
    @achievementFigure = new Visio.Figures.Circle
      width: 20
      height: 20
      percent: achievement
      number: 0


    @$el.find('.achievement-figure').html @achievementFigure.render().el
    @
