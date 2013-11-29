class Visio.Routers.OverviewRouter extends Backbone.Router

  initialize: (options) ->
    @navigation = new Visio.Views.NavigationView({
      el: $('#navigation')
    })

  routes:
    '*default': 'index'

  index: () ->
    console.log 'index'
