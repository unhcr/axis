class Visio.Routers.PdfRouter extends Backbone.Router

  initialize: (options) ->
    @selector = options.selector || 'body'

    Visio.exportModule = new Visio.Models.ExportModule options.config
    $(@selector).addClass Visio.exportModule.get('figure_config').type.name

  routes:
    '*default': 'index'

  setup: ->
    # Return empty promise if we've setup already
    return $.Deferred().resolve().promise() if Visio.manager.get('setup')

    include = Visio.exportModule.get('figure_config').includeExternalStrategyData

    Visio.manager.includeExternalStrategyData include

    figureConfig = Visio.exportModule.get('figure_config')
    figureConfig.width = $(@selector).width()
    figureConfig.height = Visio.Constants.PDF_HEIGHT
    Visio.exportModule.set 'figure_config', figureConfig

    @[Visio.exportModule.get('figure_config').type.name]?()

    filterIds = {}
    for plural, ids of Visio.manager.get('selected')
      filterIds["#{Visio.Utils.parameterByPlural(plural).singular}_ids"] = _.keys ids

    populationOptions =
      add: true
      remove: false
      type: 'POST'
      data:
        filter_ids: {}

    dashboard = Visio.manager.get 'dashboard'
    if dashboard instanceof Visio.Models.Strategy
      delete populationOptions.data.filter_ids
      populationOptions.data.strategy_id = dashboard.id
    else if dashboard instanceof Visio.Models.Operation
      populationOptions.data.filter_ids =
        operation_ids: [dashboard.id]
        ppg_ids: _.keys(dashboard.get('ppg_ids'))
        goal_ids: _.keys(dashboard.get('goal_ids'))
        problem_objective_ids: _.keys(dashboard.get('problem_objective_ids'))
        output_ids: _.keys(dashboard.get('output_ids'))
    else if Visio.manager.get('indicator')?
      populationOptions.data.filter_ids =
        operation_ids: _.keys(dashboard.get('operation_ids'))
        ppg_ids: _.keys(dashboard.get('operation_ids'))
        goal_ids: _.keys(dashboard.get('goal_ids'))

      if Visio.manager.get('indicator').get 'is_performance'
        populationOptions.data.filter_ids.problem_objective_ids =
          _.keys(dashboard.get('problem_objective_ids'))
        populationOptions.data.filter_ids.output_ids = [dashboard.id]
      else
        populationOptions.data.filter_ids.problem_objective_ids = [dashboard.id]



    $.when Visio.manager.get('expenditures').fetch(data :{ filter_ids: filterIds }, type: 'POST'),
           Visio.manager.get('budgets').fetch(data :{ filter_ids: filterIds }, type: 'POST'),
           Visio.manager.get('populations').fetch(populationOptions),
           Visio.manager.get('indicator_data').fetch(data :{ filter_ids: filterIds }, type: 'POST')

  absy: ->
    figureConfig = Visio.exportModule.get('figure_config')
    figureConfig.margin =
      left: 120
      bottom: 80
      top: 70
      right: 40

    _.each figureConfig.activeData, (d) ->
      d.d = new Visio.Models[figureConfig.collectionName](d.d)

    Visio.exportModule.set 'figure_config', figureConfig

  map: ->
    figureConfig = Visio.exportModule.get('figure_config')
    figureConfig.width = $(@selector).width()
    Visio.exportModule.set 'figure_config', figureConfig

  index: ->

    @setup().done =>
      figureConfig = Visio.exportModule.get('figure_config')
      figureConfig.isExport = false

      options = _.extend { isPdf: true, el: $(@selector) }, figureConfig

      @view = new Visio[figureConfig.viewLocation][figureConfig.type.className](options)

      $.when.apply(@, _.map(figureConfig.setupFns, (fn) =>
        @view[fn.name](fn.args))).done =>
          @view.render()



