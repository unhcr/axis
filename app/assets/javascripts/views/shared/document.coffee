class Visio.Views.Document extends Backbone.View

  initialize: ->
    fn = _.throttle @onScroll, 100

    $(document).on 'scroll', fn

  onScroll: (e) ->
    scrollTop = $(window).scrollTop()
    if $('.inner-content').length
      offset = Visio.skrollr.relativeToAbsolute($('.inner-content')[0], 'top', 'top')
    bottomOffset = 300

    headerView = Visio.router.headerView

    if scrollTop > offset and !headerView.isBreadcrumb()
      headerView.renderBreadcrumb()
    else if scrollTop <= offset and headerView.isBreadcrumb()
      headerView.render()

    if scrollTop + $(window).height() + bottomOffset > $(document).height()
      $.publish('scroll.bottom')

  close: ->
    @unbind()
