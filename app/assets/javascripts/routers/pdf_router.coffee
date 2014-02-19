class Visio.Routers.PdfRouter extends Backbone.Router

  initialize: (options) ->

    Visio.exportModule = new Visio.Models.ExportModule options.config
    $('body').addClass Visio.exportModule.get('figure_type').name

  routes:
    '*default': 'index'

  setup: ->
    # Return empty promise if we've setup already
    return $.Deferred().resolve().promise() if Visio.manager.get('setup')

    @[Visio.exportModule.get('figure_type').name]() if @[Visio.exportModule.get('figure_type').name]?

    $.when Visio.manager.get('expenditures').fetchSynced({ strategy_id: Visio.manager.get('strategy_id') }),
           Visio.manager.get('budgets').fetchSynced({ strategy_id: Visio.manager.get('strategy_id') }),
           Visio.manager.get('indicator_data').fetchSynced({ strategy_id: Visio.manager.get('strategy_id') })

  absy: ->
    figureConfig = Visio.exportModule.get('figure_config')
    figureConfig.width = $('body').width()
    figureConfig.height = 470
    figureConfig.margin =
      left: 80
      bottom: 80
      top: 70
      right: 40

    Visio.exportModule.set 'figure_config', figureConfig

  index: ->

    @setup().done =>
      figureConfig = Visio.exportModule.get('figure_config')
      figureConfig.isExport = false

      options = _.extend { isPdf: true, el: $('body') }, figureConfig

      @view = new Visio[figureConfig.viewLocation][figureConfig.type.className](options)
      @view.render()



