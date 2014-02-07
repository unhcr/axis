class Visio.Views.ParameterSearch extends Backbone.View

  className: 'parameter-search'

  template: HAML['shared/parameter_search']

  events:
    'keyup input': 'onSearch'
    'click .search-item': 'onAdd'

  initialize: (options) ->
    @throttledSearch = _.throttle @search, 300

  render: ->
    @$el.html @template()
    @

  onAdd: (e) ->
    $target = $(e.currentTarget)
    console.log $target.text()

  onSearch: (e) ->
    $target = $(e.currentTarget)

    @throttledSearch($target.val()) if $target.val().length

  search: (query) =>
    @collection.search(query).done (resp) =>
      console.log resp
      @$el.find('.results').html _.map(resp, (elasticModel) ->
        HAML['shared/search_item']({ elasticModel: elasticModel }))

      @$el.find('.results').html '' unless resp.length

  add: (model) =>
    @collection.add model
