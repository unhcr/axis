class Visio.Views.SearchView extends Backbone.View

  template: JST['shared/search']

  initialize: (options) ->
    @render()

  events:
    'blur input': 'onBlurSearch'

  render: () ->
    @$el.html @template()

  show: () ->
    @$el.removeClass('zero-max-height')
    @$el.find('input').focus()

  hide: () ->
    @$el.addClass('zero-max-height')

  onBlurSearch: () =>
    Visio.router.navigate '/'
    @hide()
