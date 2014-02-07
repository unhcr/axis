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

    id = $target.attr 'data-id'
    @add(id)


  onSearch: (e) ->
    $target = $(e.currentTarget)

    @throttledSearch($target.val()) if $target.val().length

  search: (query) =>
    @collection.search(query).done (resp) =>
      console.log resp
      @$el.find('.results').html _.map(resp, (elasticModel) ->
        HAML['shared/search_item']({ elasticModel: elasticModel }))

      @$el.find('.results').html '' unless resp.length

  filterIds: (id) =>
    filterIds = {}
    _.each _.values(Visio.Parameters), (hash) =>
      return if hash == Visio.Parameters.STRATEGY_OBJECTIVES or
                hash == Visio.Parameters.PPGS

      if hash == @collection.name
        filterIds["#{hash.singular}_ids"] = [id]
      else
        filterIds["#{hash.singular}_ids"] = Visio.manager.get(hash.plural).pluck('id')

    filterIds

  dataTypes: =>
    if @collection.name == Visio.Parameters.INDICATORS
      return [Visio.Syncables.INDICATOR_DATA]
    else
      return [Visio.Syncables.INDICATOR_DATA,
              Visio.Syncables.BUDGETS,
              Visio.Syncables.EXPENDITURES]


  add: (id) =>
    if @collection.get(id)
      selected = Visio.manager.get 'selected'
      selected[@collection.name.plural][id] = true
    else
      # Need to fetch from server for indicator/expenditure/budget data

      options =
        filter_ids: @filterIds(id)

      dataTypes = @dataTypes()
      _.each dataTypes, (dataType) ->
        Visio.manager.get(dataType.plural).fetchSynced(options, null, 'post')

