class Visio.Routers.GlobalRouter extends Backbone.Router

  initialize: (options) ->
    $.fn.tipsy.defaults =
      delayIn: 0,      # delay before showing tooltip (ms)
      delayOut: 0,     # delay before hiding tooltip (ms)
      fade: false,     # fade tooltips in/out?
      fallback: '',    # fallback text to use when no tooltip text
      gravity: 's',    # gravity
      html: true,     # is tooltip content HTML?
      live: false,     # use live event support?
      offset: 0,       # pixel offset of tooltip from element
      opacity: 0.8,    # opacity of tooltip
      title: 'title',  # attribute/callback containing tooltip text
      trigger: 'manual' # how tooltip is triggered - hover | focus | manual

    @headerView = new Visio.Views.Header({ el: $('header') })
    @menuView = new Visio.Views.MenuView()
    $('body').append @menuView.el

    @searchView = new Visio.Views.SearchView({
      el: $('#global-search')
    })

    @on 'export', (config) =>
      config = $.extend { isExport: true }, config
      model = new Visio.Models.ExportModule
        figure_type: config.type
        state: Visio.manager.state()
        figure_config: config

      @exportView = new Visio.Views.ExportModule( model: model )
      $('body').append(@exportView.render().el)

  search: () =>
    $(document).scrollTop(0)
    if @searchView.isOpen()
      @searchView.hide()
    else
      @searchView.show()
    Visio.router.navigate '/'

  menu: () =>
    $(document).scrollTop(0)
    if @menuView.isHidden() then @menuView.show() else @menuView.hide()
    Visio.router.navigate '/'
