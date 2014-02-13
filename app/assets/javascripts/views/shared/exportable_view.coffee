class Visio.Views.ExportableView extends Backbone.View

  config: ->
    config = {}
    config.collection = @collection.toJSON() if @collection?
    config.model = @model.toJSON() if @model?
    config.type = @type
    config.selectable = @selectable
    config.viewLocation = 'Views'
    config

  selectable: false

  title: 'My Awesome View'

  type: null

  events:
    'click a.export': 'onExport'

  onExport: (e) =>
    e.stopPropagation()
    Visio.router.trigger 'export', @config()

