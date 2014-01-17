class Visio.Models.Manager extends Backbone.Model

  initialize: (options) ->
    @set('db', new ydn.db.Storage(Visio.Constants.DB_NAME, Visio.Schema))
    options ||= {}

    @get('db').addEventListener 'ready', (e) =>
      if Visio.user && Visio.user.get('reset_local_db')
        @get('db').clear(Visio.Schema.stores.map((store) -> store.name))
        Visio.user.save({ reset_local_db: false })

      options.ready() if options.ready

    @get('db').addEventListener 'fail', (e) =>
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
    'strategies': new Visio.Collections.Strategy()
    'strategy_objectives': new Visio.Collections.StrategyObjective()
    'date': new Date(2012, 1)
    'use_local_db': true
    'setup': false
    'db': null
    'mapMD5': null
    'syncTimestampId': 'sync_timestamp_id_'
    'yearList': [2012, 2013, 2014, 2015]
    'selected': {}
    'selected_strategies': {}
    'aggregation_type': Visio.Parameters.PLANS.plural
    'scenario_type': {}
    'budget_type': {}
    'achievement_type': Visio.AchievementTypes.TARGET

  resetSelectedDefaults: () ->
    _.each _.values(Visio.Parameters), (hash) ->
      Visio.manager.get('selected')[hash.plural] = {}
      if hash.singular == Visio.Parameters.PLANS.singular
        plans = Visio.manager.strategy().plans().where({ year: Visio.manager.year() })
        _.each plans, (plan) ->
          Visio.manager.get('selected')[hash.plural][plan.id] = true
      else
        _.extend Visio.manager.get('selected')[hash.plural],
          Visio.manager.strategy().get("#{hash.singular}_ids")

  resetBudgetDefaults: () ->
    _.each Visio.Scenarios, (scenario) =>
      @get('scenario_type')[scenario] = true

    _.each Visio.Budgets, (budget) =>
      @get('budget_type')[budget] = true

  reset: () ->
    @resetBudgetDefaults()
    @resetSelectedDefaults()
    Visio.manager.trigger('change:selected')

  year: (year) ->
    return @get('date').getFullYear() if arguments.length == 0
    @set('date', new Date(year, 1))

  strategy: () ->
    return unless @get('strategies') && @get('strategy_id')
    @get('strategies').get(@get('strategy_id'))

  strategies: (strategy_ids) ->
    if !strategy_ids || strategy_ids.length == 0
      return @get('strategies')

    return new Visio.Collections.Strategy(@get('strategies').filter((strategy) ->
      _.include(strategy_ids.map((i) -> +i), strategy.id)
    ))

  selected: (type) ->
    parameters = @get(type)

    if type == Visio.Parameters.STRATEGY_OBJECTIVES.plural
      return @strategy()[type]()

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
    strategies = @strategies strategyIds

    planIds = strategies.map (strategy) -> _.keys(strategy.get("#{Visio.Parameters.PLANS.singular}_ids"))
    planIds = _.intersection.apply(null, planIds)

  getSyncDate: (id) ->
    db = @get('db')
    db.get(Visio.Stores.SYNC, id)

  setSyncDate: (id) ->
    d = new Date()
    db = @get('db')

    db.put(Visio.Stores.SYNC, { synced_timestamp: +d }, id)

  getMap: () ->
    db = @get('db')
    assert(@get('mapMD5'))

    $.when(db.get(Visio.Stores.MAP, @get('mapMD5'))).then((record) =>
      if !record
        return $.get('/map')
      else
        return record
    ).done((record) =>
      db.put(Visio.Stores.MAP, record, @get('mapMD5'))
    ).done(() =>
      db.get(Visio.Stores.MAP, @get('mapMD5'))
    )

  validate: (attrs, options) ->
    unless _.every(_.values(Visio.Parameters), (hash) ->
        attrs[hash.plural] instanceof Visio.Collections[hash.className])

      throw "Collection of has a mismatched collection type"

    unless _.include attrs.yearList, attrs.date.getFullYear()
      throw "Current year: #{attrs.date.getFullYear()}, is not in current year list #{attrs.yearList}"

    unless _.include Visio.AggregationTypes.map((d) -> d.plural), attrs.aggregation_type
      throw "Current aggregation_type: #{attrs.aggregation_type}, is not a valid aggregation type"

    unless _.include _.values(Visio.AchievementTypes), attrs.achievement_type
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
