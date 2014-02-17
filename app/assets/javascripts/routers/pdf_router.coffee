class Visio.Routers.PdfRouter extends Backbone.Router

  initialize: (options) ->

    Visio.exportModule = new Visio.Models.ExportModule options.config


  routes:
    '*default': 'index'

  setup: ->
    # Return empty promise if we've setup already
    return $.Deferred().resolve().promise() if Visio.manager.get('setup')

    $.when Visio.manager.get('expenditures').fetchSynced({ strategy_id: Visio.manager.get('strategy_id') }),
           Visio.manager.get('budgets').fetchSynced({ strategy_id: Visio.manager.get('strategy_id') }),
           Visio.manager.get('indicator_data').fetchSynced({ strategy_id: Visio.manager.get('strategy_id') })

  index: ->

    @setup().done =>
      figureConfig = Visio.exportModule.get('figure_config')

      options = _.extend { isPDF: true }, figureConfig

      @view = new Visio[figureConfig.viewLocation][figureConfig.type.className](options)

      $('body').prepend @view.render().el

