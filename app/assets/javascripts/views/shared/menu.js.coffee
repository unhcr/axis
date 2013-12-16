class Visio.Views.MenuView extends Backbone.View

  template: JST['shared/menu']

  className: 'container full-width menu gone overlay'

  initialize: (options) ->
    @render()

  render: () ->
    @$el.html @template({
      strategies: Visio.manager.strategies().toJSON()
    })
    @$el.css('top', $('header section').height())
    @

  show: () ->
    @$el.removeClass('gone')

  hide: () ->
    @$el.addClass('gone')
