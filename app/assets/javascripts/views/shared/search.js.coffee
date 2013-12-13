class Visio.Views.SearchView extends Backbone.View

  template: JST['shared/search']

  initialize: (options) ->
    @render()
    @throttledSearch = _.throttle @search, 300

  events:
    'blur input': 'onBlurSearch'
    'keyup input': 'onKeyupSearch'
    'transitionend': 'onTransitionEnd'
    'MSTransitionEnd': 'onTransitionEnd'
    'webkitTransitionEnd': 'onTransitionEnd'
    'oTransitionEnd': 'onTransitionEnd'

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
    $.get('/global_search', { query: query }).done (response) =>
      _.each response.operations, (operation) =>
        @$el.find('.results').append operation.highlight.name[0]

      _.each response.indicators, (indicator) =>
        @$el.find('.results').append indicator.highlight.name[0]


  onKeyupSearch: (e) =>

    query = $(e.currentTarget).val()

    @throttledSearch query

  onTransitionEnd: (e) =>
    if Visio.router.map
      Visio.router.map.refreshTooltips()

