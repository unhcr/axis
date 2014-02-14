class Visio.Views.AbsyView extends Backbone.View

  template: HAML['modules/absy']

  className: 'module'

  id: 'absy'

  events:
    'click .scenario .visio-checkbox input': 'onClickScenario'
    'click .budget .visio-checkbox input': 'onClickBudget'
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

  render: (isRerender) ->

    if !isRerender
      @$el.html @template( figureId: @figure.figureId() )
      @$el.find('#bubble').html @figure.el
      @$el.find('.figure-header').html (new Visio.Views.FilterBy({ figure: @figure, })).render().el


    @figure.collectionFn(Visio.manager.selected(Visio.manager.get('aggregation_type')))
    @figure.render()

    @
