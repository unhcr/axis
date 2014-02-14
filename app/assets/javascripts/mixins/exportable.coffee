Visio.Mixins.Exportable =
  config: ->
    config = {}

    # Add any custom attributes to the configuration
    _.each @attrConfig, (attr) =>
      config[attr] = @[attr]

    config.collection = @collection.toJSON() if @collection?
    config.model = @model.toJSON() if @model?
    config.type = @type
    config.selectable = @selectable
    config.viewLocation = @viewLocation
    config

  attrConfig: []

  viewLocation: null

  selectable: false

  title: 'My Awesome View'

  type: null

  events:
    'click a.export': 'onExport'

  onExport: (e) ->
    e.stopPropagation()
    Visio.router.trigger 'export', @config()

  subscribe: ->
    $.subscribe "select.#{@cid}.figure", @select

  events:
    'click a.export': 'onExport'

  unsubscribe: => $.unsubscribe "select.#{@cid}.figure"

  select: (e, d, i) -> console.error('No select implemented')

  filtered: (data) -> data

  figureId: -> @cid
