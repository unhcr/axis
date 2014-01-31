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
      figureId: 'absy'
      margin:
        top: 10
        bottom: 30
        left: 90
        right: 80
    Visio.FigureInstances['absy'] = Visio.Figures.absy(@config)

  render: (isRerender) ->

    if !isRerender
      @$el.html @template( figureId: 'absy' )
      @$el.find('#bubble').html Visio.FigureInstances['absy'].el()


    _.each _.keys(Visio.manager.get('scenario_type')), (scenario) =>
      @$el.find("input[value='#{scenario}']").prop('checked', true)

    _.each _.keys(Visio.manager.get('budget_type')), (budget) =>
      @$el.find("input[value='#{budget}']").prop('checked', true)

    Visio.FigureInstances['absy'].data(Visio.manager.selected(Visio.manager.get('aggregation_type')).models)
    Visio.FigureInstances['absy']()

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

    Visio.manager.trigger('change:scenario_type')

  onClickBudget: (e) =>
    $target = $(e.currentTarget)

    if $target.is(':checked')
      Visio.manager.get('budget_type')[$target.val()] = true
    else
      delete Visio.manager.get('budget_type')[$target.val()]

    Visio.manager.trigger('change:budget_type')
