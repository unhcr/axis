class Visio.Views.SearchView extends Backbone.View

  template: JST['shared/search']

  itemTemplate: JST['shared/search_item']

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
    @$el.find('.results').addClass 'gone zero-height'

  onBlurSearch: () =>
    Visio.router.navigate '/'
    @hide()

  search: (query) =>
    searchTypes = ['indicators', 'operations']
    $.get('/global_search', { query: query }).done (response) =>
      $results = @$el.find('.results')
      if _.any(searchTypes, (type) -> response[type].length > 0)
        $results.removeClass 'gone zero-height'
        $results.css 'height', $(document).height() - $results.offset().top
      else
        $results.addClass 'gone zero-height'

      _.each searchTypes, (type) =>
        html = ''
        _.each response[type], (result) =>
          html += @itemTemplate( result: result.highlight.name[0] )

        if html
          $results.find(".#{Inflection.singularize(type)}-results").html html
          $results.find(".#{Inflection.singularize(type)}-results-container").removeClass 'gone zero-height'
        else
          $results.find(".#{Inflection.singularize(type)}-results-container").addClass 'gone zero-height'


  onKeyupSearch: (e) =>

    query = $(e.currentTarget).val()

    @throttledSearch query

  onTransitionEnd: (e) =>
    if Visio.router.map
      Visio.router.map.refreshTooltips()

