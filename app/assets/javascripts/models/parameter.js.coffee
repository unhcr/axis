class Visio.Models.Parameter extends Backbone.Model

  store: () ->
    @name + '_store'

  keyPath: 'id'

  setSynced: () ->
    db = Visio.manager.get('db')
    db.put({
      name: @store()
      keyPath: @keyPath }, @toJSON())

  getSynced: () ->
    db = Visio.manager.get('db')
    db.get(@store(), @id)

  selectedIndicatorData: () ->
    return new Visio.Collections.IndicatorDatum(Visio.manager.get('indicator_data').filter((d) =>
      return _.every Visio.manager.get('types'), (type) =>
        ids = if @name == type then [@id] else Visio.manager.get('selected')[type]

        _.include ids, d.get("#{Inflection.singularize(type)}_id")))

  selectedAchievement: () ->
    data = @selectedIndicatorData()
    data.achievement()

  strategyIndicatorData: () ->
    return new Visio.Collections.IndicatorDatum(Visio.manager.get('indicator_data').filter((d) =>
      return _.every Visio.manager.get('types'), (type) =>
        ids = []
        if @name == type
          ids = [@id] if Visio.manager.strategy().include(type, @id)
        else
          ids = Visio.manager.strategy().get("#{type}_ids")

        _.include ids, d.get("#{Inflection.singularize(type)}_id")))

  budget: (data) ->
    return null unless data

    problem_objective_ids = _.uniq(data.pluck('problem_objective_id'))

    problem_objectives = Visio.manager.get('problem_objectives').filter((p) ->
      _.include(problem_objective_ids, p.id) )

    _.reduce(problem_objectives,
      (sum, p) -> return sum + p.get('budget'),
      0)

  strategyBudget: () ->
    data = @strategyIndicatorData()
    @budget(data)


  selectedBudget: () ->
    data = @selectedIndicatorData()
    @budget(data)

  toJSON: () ->
    json = _.clone(this.attributes)

    for attr, value of json
      if json[attr] instanceof Backbone.Model || json[attr] instanceof Backbone.Collection
        json[attr] = json[attr].toJSON()
    json

