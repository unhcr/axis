class Visio.Views.SearchView extends Backbone.View

  template: HAML['shared/search']

  itemTemplate: HAML['shared/search_item']

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
    @$el.find('input').val('')
    @$el.find('.results').addClass 'gone zero-height'

  onBlurSearch: () =>
    Visio.router.navigate '/'
    @hide()

  search: (query) =>
    searchTypes = [Visio.Parameters.INDICATORS, Visio.Parameters.OPERATIONS]
    $.get('/global_search', { query: query }).done (response) =>
      $results = @$el.find('.results')
      if _.any(searchTypes, (hash) -> response[hash.plural].length > 0)
        $results.removeClass 'gone zero-height'
        $results.css 'height', $(document).height() - $results.offset().top
      else
        $results.addClass 'gone zero-height'

      _.each searchTypes, (hash) =>
        html = ''
        _.each response[hash.plural], (result) =>
          html += @itemTemplate( elasticModel: elasticModel )

        if html
          $results.find(".#{hash.singular}-results").html html
          $results.find(".#{hash.singular}-results-container").removeClass 'gone zero-height'
        else
          $results.find(".#{hash.singular}-results-container").addClass 'gone zero-height'


  onKeyupSearch: (e) =>

    query = $(e.currentTarget).val()

    @throttledSearch query

  onTransitionEnd: (e) =>
    if Visio.router.map
      Visio.router.map.refreshTooltips()

