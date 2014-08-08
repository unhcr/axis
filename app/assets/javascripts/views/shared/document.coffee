class Visio.Views.Document extends Backbone.View

  initialize: ->
    fn = _.throttle @onScroll, 100

    $(document).on 'scroll', fn

  onScroll: (e) ->
    scrollTop = $(window).scrollTop()
    offset = Visio.skrollr.relativeToAbsolute($('.inner-content')[0], 'top', 'top')

    headerView = Visio.router.headerView

    if scrollTop > offset and !headerView.isBreadcrumb()
      headerView.renderBreadcrumb()
    else if scrollTop <= offset and headerView.isBreadcrumb()
      headerView.render()

  close: ->
    @unbind()
