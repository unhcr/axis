Visio.Mixins.Exportable =
  # Properties to override
  #
  # viewLocation: null
  # selectable: false
  # attrConfig: []
  # hasAxis: false
  # previewable: false

  config: ->
    config = {}

    # Add any custom attributes to the configuration
    _.each @attrConfig, (attr) =>
      config[attr] = @[attr]

    if @collection?
      config.collection = @collection.toJSON()
      config.collectionName = @collection.name.className
    if @model?
      config.model = @model.toJSON()
      config.modelName = @model.name.className

    if @filters?
      config.filters = @filters.toJSON()
    config.type = @type
    config.selectable = @selectable
    config.previewable = @previewable
    config.viewLocation = @viewLocation
    config.pdfViewLocation = @pdfViewLocation
    config.setupFns = @setupFns
    config

  # Returns where the data is stored. Usually is the collection, but can also be the model
  dataAccessor: -> @collection


  pdfView: null

  title: 'My Awesome View'

  type: null

  events:
    'click .export': 'onExport'

  onExport: (e) ->
    e.stopPropagation()
    Visio.router.trigger 'export', @config()

  subscribe: ->
    $.subscribe "active.#{@cid}.figure", @select

  selectableData: (e) ->
    @filtered @collection || @model

  selectableLabel: (d, i) ->
    Visio.Constants.ALPHABET[i]

  events:
    'click .export': 'onExport'

  unsubscribe: => $.unsubscribe "active.#{@cid}.figure"

  select: (e, d, i) -> console.error('No select implemented')

  filtered: (data) -> data

  figureId: -> @cid

  exportable: true
