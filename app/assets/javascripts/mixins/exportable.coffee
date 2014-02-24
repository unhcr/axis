Visio.Mixins.Exportable =
  config: ->
    config = {}

    # Add any custom attributes to the configuration
    _.each @attrConfig, (attr) =>
      config[attr] = @[attr]

    if @collection?
      config.collection = @collection.toJSON()
      config.collectionName = @collection.constructor.name
    if @model?
      config.model = @model.toJSON()
      config.modelName = @model.constructor.name

    if @filters?
      config.filters = @filters.toJSON()
    config.type = @type
    config.selectable = @selectable
    config.viewLocation = @viewLocation
    config.pdfViewLocation = @pdfViewLocation
    config

  # Returns where the data is stored. Usually is the collection, but can also be the model
  dataAccessor: -> @collection

  attrConfig: []

  viewLocation: null

  pdfView: null

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
