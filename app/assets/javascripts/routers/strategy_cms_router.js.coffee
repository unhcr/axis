class Visio.Routers.StrategyCMSRouter extends Backbone.Router

  initialize: (options) ->
    @strategies = Visio.manager.strategies()
    @$content = $('.cms-content')

  routes:
    'index': 'index'
    'new': 'new'
    'edit/:id': 'edit'
    'destroy/:id': 'destroy'
    'show/:id': 'show'
    'download/:id': 'download'
    '*default': 'index'

  index: ->
    @indexView.close() if @indexView?
    @indexView = new Visio.Views.StrategyCMSIndexView
      collection: @strategies
    @$content.html @indexView.el

  show: (id) ->
    @showView = new Visio.Views.StrategyCMSShowView
      model: @strategies.get(id)
      el: @$content

  new: ->
    @editView = new Visio.Views.StrategyCMSEditView
      collection: @strategies
      model: new Visio.Models.Strategy()
    @$content.html @editView.render().el

  edit: (id) ->
    @editView = new Visio.Views.StrategyCMSEditView
      collection: @strategies
      model: @strategies.get(id)
    @$content.html @editView.render().el

  destroy: (id) ->
    @strategies.get(id).destroy().done =>

      @navigate '/', { trigger: true }
