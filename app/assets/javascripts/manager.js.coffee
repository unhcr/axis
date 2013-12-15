class Visio.Models.Manager extends Backbone.Model

  initialize: () ->
    @set('db', new ydn.db.Storage(Visio.Constants.DB_NAME, Visio.Schema))
    if Visio.user.get('reset_local_db')
      @get('db').clear(Visio.Schema.stores.map((store) -> store.name))
      Visio.user.save({ reset_local_db: false })

    @resetBudgetDefaults()

  defaults:
    'plans': new Visio.Collections.Plan()
    'ppgs': new Visio.Collections.Ppg()
    'goals': new Visio.Collections.Goal()
    'outputs': new Visio.Collections.Output()
    'problem_objectives': new Visio.Collections.ProblemObjective()
    'indicators': new Visio.Collections.Indicator()
    'indicator_data': new Visio.Collections.IndicatorDatum()
    'budgets': new Visio.Collections.Budget()
    'strategies': new Visio.Collections.Strategy()
    'date': new Date()
    'setup': false
    'db': null
    'mapMD5': null
    'syncTimestampId': 'sync_timestamp_id_'
    'yearList': [2012, 2013, 2014, 2015]
    'selected': {}
    'aggregation_type': Visio.Parameters.OUTPUTS
    'scenario_type': {}
    'budget_type': {}
    'achievement_type': Visio.AchievementTypes.TARGET

  resetSelected: () ->
    _.each Visio.Types, (type) ->
      Visio.manager.get('selected')[type] = {}
      if type != Visio.Parameters.PLANS
        _.extend Visio.manager.get('selected')[type], Visio.manager.strategy().get("#{type}_ids")
      else
        plans = Visio.manager.strategy().plans().where({ year: Visio.manager.year() })
        _.each plans, (plan) ->
          Visio.manager.get('selected')[type][plan.id] = true
    console.log Visio.manager.get('selected')

  resetBudgetDefaults: () ->
    _.each Visio.Scenarios, (scenario) =>
      @get('scenario_type')[scenario] = true

    _.each Visio.Budgets, (budget) =>
      @get('budget_type')[budget] = true

  reset: () ->
    @resetBudgetDefaults()
    @resetSelected()
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
      _.include(strategy_ids, strategy.id)
    ))

  setSelected: () ->
    $navigation = $('#navigation')

    _.each Visio.Types, (type) =>
      @get('selected')[type] = {}

    $navigation.find('.visio-check input:checked').each (idx, ele) =>
      typeid = $(ele).val().split('__')

      type = typeid[0]
      id = typeid[1]
      @get('selected')[type][id] = true

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

  plans: (options) ->
    new Visio.Collections.Plan(@get('plans').where(options))

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
