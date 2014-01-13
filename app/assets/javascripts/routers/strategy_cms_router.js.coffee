class Visio.Routers.StrategyCMSRouter extends Backbone.Router

  initialize: (options) ->
    @strategies = Visio.manager.strategies()
    @$content = $('.cms-content')

  routes:
    'index': 'index'
    'new': 'new'
    'edit/:id': 'edit'
    'show/:id': 'show'
    '*default': 'index'

  index: ->
    @indexView = new Visio.Views.StrategyCMSIndexView
      collection: @strategies
      el: @$content

  show: (id) ->
    @showView = new Visio.Views.StrategyCMSShowView
      model: @strategies.get(id)
      el: @$content

  new: ->
    @newView = new Visio.Views.StrategyCMSNewView
      model: new Visio.Models.Strategy()
      el: @$content

  edit: (id) ->
    @editView = new Visio.Views.StrategyCMSNewView
      model: @strategies.get(id)
      el: @$content
