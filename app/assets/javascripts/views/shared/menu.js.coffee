class Visio.Views.MenuView extends Backbone.View

  template: HAML['shared/menu']

  className: 'container full-width menu gone overlay'

  hiddenClass: 'gone'

  initialize: (options) ->
    @render()

  render: () ->
    @$el.html @template({
      strategies: Visio.manager.strategies().toJSON()
    })
    @$el.css('top', $('header section').height())
    @

  show: () ->
    @$el.removeClass(@hiddenClass)
    $('body').removeClass('ui-invert-theme').addClass('ui-orange-theme')

  hide: () ->
    @$el.addClass(@hiddenClass)
    $('body').removeClass('ui-orange-theme').addClass('ui-invert-theme')

  isHidden: () ->
    @$el.hasClass(@hiddenClass)

