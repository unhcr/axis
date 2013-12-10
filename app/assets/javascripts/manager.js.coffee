class Visio.Models.Manager extends Backbone.Model

  initialize: () ->
    @set('db', new ydn.db.Storage(Visio.Constants.DB_NAME, Visio.Schema))
    _.each Visio.Types, (type) =>
      @get('selected')[type] = []

    _.each Visio.Scenarios, (scenario) =>
      @get('scenario_type')[scenario] = true

    _.each Visio.Budgets, (budget) =>
      @get('budget_type')[budget] = true

  defaults:
    'plans': new Visio.Collections.Plan()
    'ppgs': new Visio.Collections.Ppg()
    'goals': new Visio.Collections.Goal()
    'outputs': new Visio.Collections.Output()
    'problem_objectives': new Visio.Collections.ProblemObjective()
    'indicators': new Visio.Collections.Indicator()
    'indicator_data': new Visio.Collections.IndicatorDatum()
    'strategies': new Visio.Collections.Strategy()
    'date': new Date()
    'db': null
    'mapMD5': null
    'syncTimestampId': 'sync_timestamp_id_'
    'yearList': [2012, 2013, 2014, 2015]
    'selected': {}
    'aggregation_type': Visio.Parameters.OUTPUTS
    'scenario_type': {}
    'budget_type': {}

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
      @get('selected')[type] = []

    $navigation.find('.visio-check input:checked').each (idx, ele) =>
      typeid = $(ele).val().split('__')

      type = typeid[0]
      id = typeid[1]
      @get('selected')[type].push id

  selected: (type) ->
    ids = @get('selected')[type]

    parameters = @get(type)

    return new parameters.constructor(parameters.filter((p) -> return _.include(ids, p.id)) )

  selectedIndicatorData: () ->
    return new Visio.Collections.IndicatorDatum(@get('indicator_data').filter((d) =>
      return _.every Visio.Types, (type) =>
        _.include(@get('selected')[type], d.get("#{Inflection.singularize(type)}_id"))
    ))

  plan: (idOrISO) ->
    if idOrISO.length == 3
      plan = @get('plans').find((p) =>
        if p.get('country')
          p.get('country').iso3 == idOrISO && p.get('year') == @year()
        else
          false
      )
      return plan
    else
      return @get('plans').get(idOrISO)

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
