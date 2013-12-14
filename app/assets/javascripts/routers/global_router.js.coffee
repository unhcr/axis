class Visio.Routers.GlobalRouter extends Backbone.Router

  initialize: (options) ->
    @menuView = new Visio.Views.MenuView()
    $('body').append @menuView.el

    @searchView = new Visio.Views.SearchView({
      el: $('#global-search')
    })

  search: () =>
    $(document).scrollTop(0)
    @searchView.show()

  menu: () =>
    $(document).scrollTop(0)
    @menuView.show()
