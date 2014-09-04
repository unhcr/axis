class Visio.Views.FilterSystemView extends Backbone.View

  templateFilters: HAML['shared/filter_system/filters']
  templatePages: HAML['shared/filter_system/pages']
  templateStrategies: HAML['shared/filter_system/strategies']
  templatePageList: HAML['shared/filter_system/page_list']

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
      fn: 'renderPages'
      human: 'Operation'
    },
    {
      type: 'indicators'
      fn: 'renderPages'
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
    'keyup .page-filter': 'onFilterPages'

  render: (type = 'filters') ->
    option = _.findWhere Visio.Views.FilterSystemView.OPTIONS, { type: type }

    throw new Error('Invalid filter system view') unless option

    @[option.fn](option)
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
        # Either it's selected or it's part of the strategy or it's been custom loaded
        Visio.manager.get('selected')[hash.plural][d.id] or
          Visio.manager.get('dashboard').include(hash.singular, d.id) or
          d.get('loaded')

      parameters.push
        data: data
        hash: hash

    @$el.html @templateFilters
      dashboard: Visio.manager.get('dashboard')
      parameters: parameters
      options: Visio.Views.FilterSystemView.OPTIONS
      selected: 'filters'

    _.each @searches, (view) =>
      plural = view.collection.name.plural
      $target = @$el.find(".ui-accordion-content.#{plural}")
      $target.prepend view.render().el

  renderPages: (option) ->
    @$el.addClass 'filter-system-orange'
    @$el.html @templatePages
      options: Visio.Views.FilterSystemView.OPTIONS
      selected: option.type

    if @[option.type].length > 0
      @$el.find('.system-list').html @templatePageList
        models: @[option.type].models
    else
      NProgress.start()
      @[option.type].fetch().done =>
        @$el.find('.system-list').html @templatePageList
          models: @[option.type].models
        NProgress.done()

  renderStrategies: ->
    @$el.addClass 'filter-system-orange'

    @$el.html @templateStrategies
      strategies: Visio.manager.strategies().toJSON()
      personalStrategies: Visio.manager.personalStrategies().toJSON()
      sharedStrategies: Visio.manager.sharedStrategies().toJSON()
      options: Visio.Views.FilterSystemView.OPTIONS
      selected: 'strategies'

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

  onFilterPages: (e) =>
    $target = $ e.currentTarget
    type = $target.data().type
    query = $target.val()
    @filterPages query, type

  filterPages: (query, type) =>
    query = query.toLowerCase().trim()

    if query
      @$el.find('.system-list').html @templatePageList
        models: @[type].filter (model) ->
          model.toString().toLowerCase().indexOf(query) != -1

    else
      @$el.find('.system-list').html @templatePageList
        models: @[type].models


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


