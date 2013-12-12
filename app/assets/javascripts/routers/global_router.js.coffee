class Visio.Routers.GlobalRouter extends Backbone.Router

  initialize: (options) ->
    @menuView = new Visio.Views.MenuView()
    $('body').append @menuView.el

    @searchView = new Visio.Views.SearchView({
      el: $('#global-search')
    })

  search: () =>
    @searchView.show()
