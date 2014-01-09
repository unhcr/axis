class Visio.Routers.StrategyCMSRouter extends Backbone.Router

  initialize: (options) ->
    @strategies = options.strategies

  routes:
    'index': 'index'
    'new': 'new'
    'edit/:id': 'edit'
    '*default': 'index'

  index: ->
    @indexView = new Visio.Views.StrategyCMSIndexView(strategies: @strategies)

  new: ->
    @newView = new Visio.Views.StrategyCMSNewView()

  edit: (id) ->
    @editView = new Visio.Views.StrategyCMSEditView(strategy: @strategies.get(id))
