class Visio.Views.SearchView extends Backbone.View

  template: JST['shared/search']

  initialize: (options) ->
    @render()
    @throttledSearch = _.throttle @search, 300

  events:
    'blur input': 'onBlurSearch'
    'keyup input': 'onKeyupSearch'

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

  search: (query) =>

  onKeyupSearch: (e) =>

    query = $(e.currentTarget).val()

    @throttledSearch query

