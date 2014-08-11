module 'Header Test',

  setup: ->
    Visio.user = new Visio.Models.User()
    Visio.manager = new Visio.Models.Manager()
    Visio.manager.set 'dashboard', (new Visio.Models.Strategy())

    @view = new Visio.Views.Header()

  teardown: ->
    @view.close()

test 'render normal', ->

  @view.render()

  strictEqual @view.$el.find('.menu-options .dashboard-item').length, _.values(@view.menuOptions).length

  ok !@view.isBreadcrumb()

test 'render breadcrumb', ->
  @view.renderBreadcrumb()
  strictEqual @view.$el.find('.dashboard-item').length, _.values(@view.menuOptions).length
  ok @view.$el.hasClass 'breadcrumb'
  ok @view.isBreadcrumb()

test 'setup filterSystem', ->

  ok !@view.filterSystem?

  Visio.manager.set 'setup', true

  ok @view.filterSystem?

test 'click dashboard item', ->

  @view.render()
  ok !@view.isOpenOptionMenu()

  @view.$el.find('.menu-options .dashboard-item:first').trigger 'click'
  ok @view.isOpenOptionMenu()

  @view.$el.find('.menu-options .dashboard-item:first').trigger 'click'
  ok !@view.isOpenOptionMenu()

  @view.$el.find('.menu-options .dashboard-item:first').trigger 'click'
  ok @view.isOpenOptionMenu()

  @view.$el.find('.menu-options .dashboard-item:last').trigger 'click'
  ok @view.isOpenOptionMenu()
