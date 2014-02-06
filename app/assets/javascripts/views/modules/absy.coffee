class Visio.Views.AbsyView extends Backbone.View

  template: HAML['modules/absy']

  className: 'module'

  id: 'absy'

  events:
    'click .scenario .visio-check input': 'onClickScenario'
    'click .budget .visio-check input': 'onClickBudget'
    'change .achievement-type-toggle': 'onAchievementTypeChange'

  initialize: (options) ->
    @config =
      width: 600
      height: 320
      margin:
        top: 10
        bottom: 30
        left: 90
        right: 80

    @figure = new Visio.Figures.Absy @config
    Visio.FigureInstances[@figure.figureId()] = @figure

  render: (isRerender) ->

    if !isRerender
      @$el.html @template( figureId: @figure.figureId() )
      @$el.find('#bubble').html @figure.el
      @$el.find('.figure-header').html (new Visio.Views.FilterBy({ figure: @figure, })).render().el


    @figure.dataFn(Visio.manager.selected(Visio.manager.get('aggregation_type')).models)
    @figure.render()

    @

  onAchievementTypeChange: (e) =>
    if Visio.manager.get('achievement_type') == Visio.AchievementTypes.TARGET
      achievement_type = Visio.AchievementTypes.STANDARD
    else
      achievement_type = Visio.AchievementTypes.TARGET

    Visio.manager.set 'achievement_type', achievement_type
