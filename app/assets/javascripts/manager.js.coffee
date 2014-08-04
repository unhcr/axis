class Visio.Models.Manager extends Backbone.Model

  initialize: (options) ->
    # fill in defaults if they exist
    Visio.configuration or= {}

    if Visio.configuration.startyear? and Visio.configuration.endyear?
      @set 'yearList', [Visio.configuration.startyear..Visio.configuration.endyear]

    @set 'date', new Date(Visio.configuration.default_date, 1) if Visio.configuration.default_date?

    for key, value of Visio.configuration
      if key.startsWith('default_') and key != 'default_date'
        k = key.replace 'default_', ''
        @set k, value

    isSafari = navigator.userAgent.indexOf('Safari') != -1 and
               navigator.userAgent.indexOf('Chrome') == -1

    # Disable local db for safari since it's way too slow
    @set('use_local_db', false) if isSafari

    if @get('use_local_db')
      @set('db', new ydn.db.Storage(Visio.Constants.DB_NAME, Visio.Schema))

    options ||= {}

    @state options.state if options.state?

    @get('db')?.addEventListener 'ready', (e) =>
      if Visio.user && Visio.user.get('reset_local_db')
        @get('db').clear(Visio.Schema.stores.map((store) -> store.name))
        Visio.user.save({ reset_local_db: false })

      options.ready() if options.ready

    @get('db')?.addEventListener 'fail', (e) =>
      alert 'Your data will not be saved because offline storage is not actived. Try using a modern browser like Google Chrome'

      console.error e.name
      @set 'use_local_db', false

    @resetBudgetDefaults()

    # Automatically change date if we change year
    @on 'change:year', =>
      @year(@get('year'))

  defaults:
    'operations': new Visio.Collections.Operation()
    'plans': new Visio.Collections.Plan()
    'ppgs': new Visio.Collections.Ppg()
    'goals': new Visio.Collections.Goal()
    'outputs': new Visio.Collections.Output()
    'problem_objectives': new Visio.Collections.ProblemObjective()
    'indicators': new Visio.Collections.Indicator()
    'indicator_data': new Visio.Collections.IndicatorDatum()
    'budgets': new Visio.Collections.Budget()
    'expenditures': new Visio.Collections.Expenditure()
    'strategies': new Visio.Collections.Strategy()
    'personal_strategies': new Visio.Collections.Strategy()
    'shared_strategies': new Visio.Collections.Strategy()
    'strategy_objectives': new Visio.Collections.StrategyObjective()
    'date': new Date(2013, 1)
    'use_local_db': true
    'setup': false
    'db': null
    'syncTimestampId': 'sync_timestamp_id_'
    'yearList': [2012, 2013, 2014, 2015]
    'selected': {}
    'selected_strategies': {}
    'aggregation_type': Visio.Parameters.OPERATIONS.plural
    'scenario_type': {}
    'budget_type': {}
    'achievement_type': Visio.Algorithms.GOAL_TYPES.target
    'amount_type': Visio.Syncables.BUDGETS
    'reported_type': Visio.Algorithms.REPORTED_VALUES.yer
    'dashboard': null

  resetSelectedDefaults: () ->
    _.each _.values(Visio.Parameters), (hash) ->
      Visio.manager.get('selected')[hash.plural] = {}
      _.extend Visio.manager.get('selected')[hash.plural],
        Visio.manager.get('dashboard').get("#{hash.singular}_ids")

      # include dashboard's own id
      if Visio.manager.get('dashboard').name == hash
        Visio.manager.select hash.plural, Visio.manager.get('dashboard').id

    # include all strategy objectives if we are not looking at a strategy dashboard
    unless Visio.manager.get('dashboard').get('isStrategy')
      Visio.manager.select Visio.Parameters.STRATEGY_OBJECTIVES.plural,
        Visio.manager.get(Visio.Parameters.STRATEGY_OBJECTIVES.plural).pluck('id')

    if Visio.manager.includeExternalStrategyData()
      Visio.manager.select Visio.Parameters.STRATEGY_OBJECTIVES.plural,
        Visio.Constants.ANY_STRATEGY_OBJECTIVE

  resetBudgetDefaults: () ->
    _.each Visio.Scenarios, (scenario) =>
      @get('scenario_type')[scenario] = true

    _.each Visio.Budgets, (budget) =>
      @get('budget_type')[budget] = true

  reset: () ->
    @resetBudgetDefaults()
    @resetSelectedDefaults()
    Visio.manager.trigger('change:selected')

  includeExternalStrategyData: (include) =>
    unless include?
      return Visio.manager.get('strategy_objectives').get(Visio.Constants.ANY_STRATEGY_OBJECTIVE)?


    if include
      Visio.manager.get('strategy_objectives').add
        id: Visio.Constants.ANY_STRATEGY_OBJECTIVE
        name: 'External Data'
    else
      Visio.manager.get('strategy_objectives').remove Visio.Constants.ANY_STRATEGY_OBJECTIVE

  isDashboardPersonal: ->
    Visio.manager.get('personal_strategies').get(Visio.manager.get('dashboard').id)?

  year: (_year, options) ->
    return @get('date').getFullYear() if arguments.length == 0
    @set { date: new Date(_year, 1) }, options || {}

  strategy: () ->
    return unless (@get('strategies') or @get('personal_strategies')) && @get('strategy_id')
    strategy = @get('strategies').get(@get('strategy_id'))

    # Look for strategy in personal strategies if it's not global
    unless strategy
      strategy = @get('personal_strategies').get(@get('strategy_id'))

    # Look for strategy in shared strategies if it's not global
    unless strategy
      strategy = @get('shared_strategies').get(@get('strategy_id'))

    strategy

  strategies: (strategyIds) ->
    return @get('strategies') unless strategyIds?

    return new Visio.Collections.Strategy(@get('strategies').filter((strategy) ->
      _.include(strategyIds.map((i) -> +i), strategy.id)
    ))

  personalStrategies: (strategyIds) ->
    return @get('personal_strategies') unless strategyIds?

    return new Visio.Collections.Strategy(@get('personal_strategies').filter((strategy) ->
      _.include(strategyIds.map((i) -> +i), strategy.id)
    ))

  sharedStrategies: (strategyIds) ->
    return @get('shared_strategies') unless strategyIds?

    return new Visio.Collections.Strategy(@get('shared_strategies').filter((strategy) ->
      _.include(strategyIds.map((i) -> +i), strategy.id)
    ))

  select: (type, ids) ->
    selected = @get 'selected'

    if _.isArray ids
      _.each ids, (id) ->
        selected[type][id] = true
    else if ids?
      # Must be single id
      selected[type][ids] = true

    @set 'selected', selected

  selected: (type) ->
    parameters = @get(type)

    return new parameters.constructor(parameters.filter((p) => @get('selected')[type][p.id]) )

  plan: (idOrISO) ->
    plan = @get('plans').get(idOrISO)

    if !plan
      plan = @get('plans').find (p) =>
        if p.get('country')
          p.get('country').iso3 == idOrISO && p.get('year') == @year()
        else
          false

    return plan

  # Returns plan ids from selected strategies
  selectedStrategyPlanIds: () ->
    strategyIds = _.keys @get('selected_strategies')

    return [] if _.isEmpty strategyIds
    strategies = @strategies strategyIds

    planIds = strategies.map (strategy) -> _.keys(strategy.get("#{Visio.Syncables.PLANS.singular}_ids"))
    planIds = _.intersection.apply(null, planIds)

  getSyncDate: (id) ->
    return $.Deferred().resolve().promise() unless @get 'use_local_db'

    db = @get('db')
    db.get(Visio.Stores.SYNC, id)

  setSyncDate: (id) ->
    return $.Deferred().resolve().promise() unless @get 'use_local_db'
    d = new Date()

    db = @get('db')
    db.put(Visio.Stores.SYNC, { synced_timestamp: +d }, id)

  validate: (attrs, options) ->
    unless _.every(_.values(Visio.Parameters), (hash) ->
        attrs[hash.plural] instanceof Visio.Collections[hash.className])

      throw "Collection of has a mismatched collection type"

    unless _.include attrs.yearList, attrs.date.getFullYear()
      throw "Current year: #{attrs.date.getFullYear()}, is not in current year list #{attrs.yearList}"

    unless _.include Visio.AggregationTypes.map((d) -> d.plural), attrs.aggregation_type
      throw "Current aggregation_type: #{attrs.aggregation_type}, is not a valid aggregation type"

    unless _.include _.values(Visio.Algorithms.GOAL_TYPES), attrs.achievement_type
      throw "Current achievement_type: #{attrs.achievement_type}, is not a valid achievement type"

  set: (key, val, options) ->
    # Default validation on set
    options or= {}

    if typeof key == 'object'
      options = val
      options.validate = true unless options.validate
      Backbone.Model.prototype.set.apply @, [key, options]
    else
      options.validate = true unless options.validate
      Backbone.Model.prototype.set.apply @, [key, val, options]

  state: (_state) ->
    if _state?
      @set 'selected', _state.selected
      @year _state.year
      @set 'achievement_type', _state.achievement_type
      @set 'scenario_type', _state.scenario_type
      @set 'budget_type', _state.budget_type
      @set 'aggregation_type', _state.aggregation_type
      @set 'amount_type', _state.amount_type
      @set 'strategies', new Visio.Collections.Strategy _state.strategies
      @set 'selected_strategies', _state.selected_strategies
      @set 'strategy_id', _state.strategy_id
      return _state
    else
      return {
        selected: @get 'selected'
        year: @year()
        achievement_type: @get 'achievement_type'
        aggregation_type: @get 'aggregation_type'
        scenario_type: @get 'scenario_type'
        budget_type: @get 'budget_type'
        amount_type: @get 'amount_type'
        strategies: @get('strategies').toJSON()
        selected_strategies: @get 'selected_strategies'
        strategy_id: @get 'strategy_id'
      }

