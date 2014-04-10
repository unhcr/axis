class Visio.Views.ParameterShowView extends Backbone.View

  tagName: 'article'

  className: 'parameter-show pbi-avoid'

  template: HAML['shared/parameter_show']

  barConfig:
    width: 200
    height: 110
    orientation: 'left'
    hasLabels: true
    margin:
      top: 2
      bottom: 2
      left: 30
      right: 10

  initialize: (options) ->
    @idx = options.idx
    @filters = options.filters
    @achievementFigure = new Visio.Figures.Pasy _.clone(@barConfig)

  render: ->

    cols = []
    rows = ['dummy']

    _.each _.values(Visio.Budgets), (budgetType) =>
      cols.push budgetType if @filters.filter('budget_type', budgetType)

    _.each _.values(Visio.Scenarios), (scenario) =>
      rows.push scenario if @filters.filter('scenario', scenario)

    achievement = @model.selectedAchievement(Visio.manager.year(), @filters)
    @$el.html @template
      model: @model
      idx: @idx
      cols: cols
      rows: rows
      filters: @filters
      achievement: achievement

    @achievementPercent = new Visio.Figures.Circle
      width: 20
      height: 20
      percent: achievement.result
      number: 0


    @$el.find('.achievement-percent').html @achievementPercent.render().el
    @$el.find('.achievement-figure').html @achievementFigure.el
    @drawAchievements()
    @

  drawAchievements: =>
    result = @model.strategyAchievement Visio.manager.year(), @filters
    @achievementFigure.modelFn new Backbone.Model result
    @achievementFigure.render()

    @$el.find(".#{Visio.FigureTypes.PASY.name}-type-count-#{@cid}").text result.typeTotal
    @$el.find(".#{Visio.FigureTypes.PASY.name}-selected-count-#{@cid}").text result.total

