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

    @[Visio.exportModule.get('figure_config').type.name]() if @[Visio.exportModule.get('figure_config').type.name]?

    filterIds = {}
    for plural, ids of Visio.manager.get('selected')
      filterIds["#{Visio.Utils.parameterByPlural(plural).singular}_ids"] = _.keys ids

    $.when Visio.manager.get('expenditures').fetch(data :{ filter_ids: filterIds }, type: 'POST'),
           Visio.manager.get('budgets').fetch(data :{ filter_ids: filterIds }, type: 'POST'),
           Visio.manager.get('indicator_data').fetch(data :{ filter_ids: filterIds }, type: 'POST')

  absy: ->
    figureConfig = Visio.exportModule.get('figure_config')
    figureConfig.width = $(@selector).width()
    figureConfig.height = 470
    figureConfig.margin =
      left: 80
      bottom: 80
      top: 70
      right: 40

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



