class Visio.Routers.StrategyCMSRouter extends Backbone.Router

  initialize: (options) ->
    @strategies = options.strategies

  routes:
    'index': 'index'
    'new': 'new'
    'edit/:id': 'edit'
    '*default': 'index'

  index: ->
    @indexView = new Visio.Views.StrategyCMSIndexView
      collection: @strategies
      el: $('.cms-content')


  new: ->
    @newView = new Visio.Views.StrategyCMSNewView
      model: new Visio.Models.Strategy()
      el: $('.cms-content')

  edit: (id) ->
    @editView = new Visio.Views.StrategyCMSEditView
      model: @strategies.get(id)
      el: $('.cms-content')
