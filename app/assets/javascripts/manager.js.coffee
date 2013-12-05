class Visio.Models.Manager extends Backbone.Model

  initialize: () ->
    @set('db', new ydn.db.Storage(Visio.Constants.DB_NAME, Visio.Schema))
    _.each @get('types'), (type) =>
      @get('selected')[type] = []

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
    'types': [
      Visio.Parameters.PLANS,
      Visio.Parameters.PPGS,
      Visio.Parameters.GOALS,
      Visio.Parameters.OUTPUTS,
      Visio.Parameters.PROBLEM_OBJECTIVES,
      Visio.Parameters.INDICATORS,
    ]

  year: () ->
    @get('date').getFullYear()

  setYear: (year) ->
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

  selected: (type) ->
    ids = @get('selected')[type]

    parameters = @get(type)

    return new parameters.constructor(parameters.filter((p) -> return _.include(ids, p.id)) )

  selectedIndicatorData: () ->
    return new Visio.Collections.IndicatorDatum(@get('indicator_data').filter((d) =>
      return _.every @get('types'), (type) =>
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
    @get('plans').where(options)

  targetPlans: ()->
    return new Visio.Collections.Plan(@get('plans').filter((plan) =>
      _.include @strategy().get('plans_ids'), plan.id))

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
