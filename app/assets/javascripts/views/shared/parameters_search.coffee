class Visio.Views.ParameterSearch extends Backbone.View

  className: 'parameter-search full-width'

  template: HAML['shared/parameter_search']

  events:
    'keyup input': 'onSearch'
    'click .search-item': 'onAdd'


  initialize: (options) ->
    @throttledSearch = _.throttle @search, 300

  render: ->
    @$el.html @template()
    @

  parameter: =>
    @collection.name

  onAdd: (e) ->
    $target = $(e.currentTarget)

    id = $target.attr 'data-id'
    @add(id)

  clear: =>
    @$el.find('.results').html ''
    @$el.find('.results').addClass 'no-border'


  onSearch: (e) ->
    $target = $(e.currentTarget)

    if $target.val().length
      @throttledSearch($target.val())
    else
      @clear()

  search: (query) =>
    @collection.search(query).done (resp) =>
      @$el.find('.results').removeClass 'no-border'
      @$el.find('.results').html _.map(resp, (elasticModel) =>
        HAML['shared/parameter_search_item']({ model: new @collection.model(elasticModel) }))

      @clear() unless resp.length

  filterIds: (parameterType, id) =>
    filterIds = {}
    _.each _.values(Visio.Parameters), (hash) =>
      return if hash == Visio.Parameters.STRATEGY_OBJECTIVES or
                hash == Visio.Parameters.PPGS

      if hash == parameterType
        filterIds["#{hash.singular}_ids"] = [id]
      else
        filterIds["#{hash.singular}_ids"] = Visio.manager.get(hash.plural).pluck('id')

    filterIds

  dataTypes: (parameterType) =>
    if parameterType == Visio.Parameters.INDICATORS
      return [Visio.Syncables.INDICATOR_DATA]
    else
      return [Visio.Syncables.INDICATOR_DATA,
              Visio.Syncables.BUDGETS,
              Visio.Syncables.EXPENDITURES]

  dependencyTypes: (parameterType) =>
    if parameterType == Visio.Parameters.OPERATIONS
      return [Visio.Parameters.PPGS]
    else if parameterType == Visio.Parameters.STRATEGY_OBJECTIVES
      return [Visio.Parameters.GOALS,
              Visio.Parameters.OUTPUTS,
              Visio.Parameters.PROBLEM_OBJECTIVES,
              Visio.Parameters.INDICATORS]
    else
      []

  add: (id) =>
    dependencyTypes = @dependencyTypes @collection.name
    dataTypes = @dataTypes @collection.name

    fetchOptions = { include: { ids: true } }

    return if @collection.get(id)? and @collection.get(id).get('loaded')

    model = new Visio.Models[@collection.name.className]({ id: id })

    # First fetch the actual parameter
    dfd = model.fetch({ data: options: fetchOptions })

    # Need to fetch from server for indicator/expenditure/budget data

    # First fetch all dependencies

    dependencyOptions =
      add: true
      remove: false
      data:
        join_ids: {}
    dependencyOptions.join_ids["#{@collection.name.singular}_id"] = id
    dataOptions = {}


    NProgress.start()
    # Have to cascade promises since jquery's when doesn't properly return promise when called with apply
    dfd.done =>
      Visio.manager.get(model.name.plural).add model
      NProgress.inc()
      # Fetch all parameter dependencies
      $.when.apply(@, dependencyTypes.map (dependencyType) ->
        Visio.manager.get(dependencyType.plural).fetch(dependencyOptions)).done =>
          NProgress.inc()

          # Select model and dependencies
          Visio.manager.select model.name.plural, id
          _.each dependencyTypes, (dependencyType) ->
            Visio.manager.select dependencyType.plural, _.keys(model.get("#{dependencyType.singular}_ids"))

          dataOptions =
            add: true
            remove: false
            data:
              filter_ids: @filterIds @collection.name, id
          $.when.apply(@, dataTypes.map (dataType) ->
            Visio.manager.get(dataType.plural).fetch(dataOptions)).done =>
              NProgress.done()
              # finally trigger redraw
              model.set 'loaded', true
              Visio.manager.trigger 'change:filter_system'


  close: ->
    @unbind()
    @remove()
