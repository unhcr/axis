class Visio.Views.FilterSystemView extends Backbone.View

  templateFilters: HAML['shared/filter_system/filters']
  templateOperations: HAML['shared/filter_system/operations']
  templateStrategies: HAML['shared/filter_system/strategies']
  templateIndicators: HAML['shared/filter_system/indicators']

  @OPTIONS: [
    {
      type: 'filters'
      fn: 'renderFilters'
      human: 'Filter'
    },
    {
      type: 'strategies'
      fn: 'renderStrategies'
      human: 'Strategy'
    }
    {
      type: 'operations'
      fn: 'renderOperations'
      human: 'Operation'
    },
    {
      type: 'indicators'
      fn: 'renderIndicators'
      human: 'Indicator'
    }
  ]

  initialize: () ->
    @operations = new Visio.Collections.Operation()
    @indicators = new Visio.Collections.Indicator()

  events:
    'click .open': 'onClickOpen'
    'click .filter-option': 'onClickFilterOption'
    'click .deselect': 'onDeselect'
    'click .reset': 'onReset'
    'change .visio-checkbox input': 'onChangeSelection'

  render: (type = 'filters') ->
    option = _.findWhere Visio.Views.FilterSystemView.OPTIONS, { type: type }

    throw new Error('Invalid filter system view') unless option

    @[option.fn]()
    @


  renderFilters: ->
    unless Visio.manager.get('dashboard')?
      throw new Error('No dashboard present, cannot render filters')

    @$el.removeClass 'filter-system-orange'
    _.each @searches, (searchView) -> searchView.close() if @searches?

    @searches = _.map _.values(Visio.Parameters), (hash) ->
      new Visio.Views.ParameterSearch({ collection: Visio.manager.get(hash.plural) })

    parameters = []

    _.each _.values(Visio.Parameters), (hash) ->

      # Skip if it is operation dashboard then don't include the operation in the navigation
      return if Visio.manager.get('indicator') and Visio.Parameters.INDICATORS == hash

      return if Visio.manager.get('dashboard').name == hash and not Visio.manager.get('indicator')?


      data = Visio.manager.get(hash.plural)
      data = _.filter data.models, (d) ->
        Visio.manager.get('dashboard').include(hash.singular, d.id)

      parameters.push
        data: data
        hash: hash

    @$el.html @templateFilters
      dashboard: Visio.manager.get('dashboard')
      parameters: parameters
      options: Visio.Views.FilterSystemView.OPTIONS

    _.each @searches, (view) =>
      plural = view.collection.name.plural
      $target = @$el.find(".ui-accordion-content.#{plural}")
      $target.prepend view.render().el

  renderOperations: ->
    @$el.addClass 'filter-system-orange'

    if @operations.length > 0
      @$el.html @templateOperations
        operations: @operations
        options: Visio.Views.FilterSystemView.OPTIONS
    else
      @operations.fetch().done =>
        @$el.html @templateOperations
          operations: @operations
          options: Visio.Views.FilterSystemView.OPTIONS

  renderIndicators: ->
    @$el.addClass 'filter-system-orange'

    if @indicators.length > 0
      @$el.html @templateIndicators
        indicators: @indicators
        options: Visio.Views.FilterSystemView.OPTIONS
    else
      @indicators.fetch().done =>
        @$el.html @templateIndicators
          indicators: @indicators
          options: Visio.Views.FilterSystemView.OPTIONS

  renderStrategies: ->
    @$el.addClass 'filter-system-orange'

    @$el.html @templateStrategies
      strategies: Visio.manager.strategies().toJSON()
      personalStrategies: Visio.manager.personalStrategies().toJSON()
      sharedStrategies: Visio.manager.sharedStrategies().toJSON()
      options: Visio.Views.FilterSystemView.OPTIONS

  onChangeSelection: (e) ->
    $target = $(e.currentTarget)

    typeid = $target.val().split(Visio.Constants.SEPARATOR)

    type = typeid[0]
    id = typeid[1]

    dashboard = Visio.manager.get('dashboard')
    # Hack for singular form of parameter
    singular = type.slice(0,  -1)

    if dashboard.include(singular, id) or
        Visio.manager.get(type).get(id)?.get('loaded') or
        id == Visio.Constants.ANY_STRATEGY_OBJECTIVE

      if $target.is(':checked')
        Visio.manager.get('selected')[type][id] = true
      else
        delete Visio.manager.get('selected')[type][id]

      Visio.manager.trigger 'change:selected', type

    else
      # Need to load external parameters, equivalent to search
      search = _.find @searches, (s) -> s.parameter().plural is type
      search.add id

  onClickFilterOption: (e) =>
    $target = $(e.currentTarget)
    return if $target.hasClass 'selected'

    @$el.find('.filter-option.selected').removeClass 'selected'
    $target.addClass 'selected'

    @render $target.data().system

  onClickOpen: (e) ->
    type = $(e.currentTarget).attr('data-type')
    @open type

  onDeselect: (e) ->
    type = $(e.currentTarget).attr('data-type')
    @$el.find(".#{type} input").prop 'checked', false

    # Clear out any selection
    Visio.manager.get('selected')[type] = {}

    Visio.manager.trigger 'change:selected', type

  onReset: (e) ->
    type = $(e.currentTarget).attr('data-type')
    ids = Visio.manager.get('dashboard')[type]().map (m) -> m.id
    @$el.find(".#{type} input").prop 'checked', false
    _.each ids, (id) =>
      @$el.find("#check_#{id}_#{type}").prop 'checked', true

    # Revert to strategy selections
    Visio.manager.get('selected')[type] = _.object(ids, _.map(ids, -> true))

    Visio.manager.trigger 'change:selected', type

  toggleState: (type) ->
    $('.page').toggleClass 'shift'
    @$el.toggleClass 'gone'

  isOpen: =>
    !@$el.hasClass('gone')

  open: (type) =>
    $names = @$el.find '.name'


    $opened = @$el.find('.ui-accordion-content.opened')
    if $opened.attr('data-type') == type
      $opened.toggleClass('opened')
      @$el.find(".name[data-type=\"#{type}\"]").toggleClass 'opened'
    else
      $names.removeClass 'opened'
      $opened.removeClass('opened')
      @$el.find(".ui-accordion-content.#{type}").addClass('opened')
      @$el.find(".name[data-type=\"#{type}\"]").addClass 'opened'

  close: ->
    @unbind()
    @remove()


