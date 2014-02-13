class Visio.Figures.Exportable extends Visio.Figures.Base

  attrConfig: ['margin', 'data', 'width', 'height']

  initialize: (config) ->
    super config
    @$el.prepend $('<a class="export">export</a>')

    $.subscribe "select.#{@cid}.figure", @select


  selectable: true

  events:
    'click a.export': 'onExport'

  onExport: (e) =>
    e.stopPropagation()
    Visio.router.trigger 'export', @config()

  config: =>
    config = {}

    _.each @attrConfig, (attr) =>
      config[attr] = @[attr]

    config.height = @originalHeight
    config.width = @originalWidth
    config.type = @type
    config.selectable = true
    config.viewLocation = 'Figures'

    config

  type: null

  unsubscribe: => $.unsubscribe "select.#{@cid}.figure"

  select: (e, d, i) -> console.error('No select implemented')

  filtered: (data) -> data

  figureId: -> @cid
