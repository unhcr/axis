class Visio.Models.Parameter extends Backbone.Model

  store: () ->
    @name + '_store'

  keyPath: 'id'

  toString: () ->
    return @get('name')

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
      return _.every Visio.Types, (type) =>
        ids = if @name == type then [@id] else Visio.manager.get('selected')[type]

        _.include ids, d.get("#{Inflection.singularize(type)}_id")))

  selectedBudgetData: () ->
    return new Visio.Collections.Budget(Visio.manager.get('budgets').filter((d) =>
      return _.every Visio.Types, (type) =>
        return true if type == Visio.Parameters.INDICATORS

        if @name == type
          ids = [@id]
        else if type == Visio.Parameters.OUTPUTS
          ids = Visio.manager.get('selected')[type].concat([undefined])
        else
          ids = Visio.manager.get('selected')[type]

        _.include ids, d.get("#{Inflection.singularize(type)}_id")))


  selectedAchievement: () ->
    data = @selectedIndicatorData()
    data.achievement()

  selectedBudget: () ->
    data = @selectedBudgetData()
    data.budget()

  strategyIndicatorData: (strategy) ->
    strategy ||= Visio.manager.strategy()

    return new Visio.Collections.IndicatorDatum(Visio.manager.get('indicator_data').filter((d) =>
      return _.every Visio.Types, (type) =>
        ids = []
        if @name == type
          ids = [@id] if strategy.include(type, @id)
        else
          ids = strategy.get("#{type}_ids")

        _.include ids, d.get("#{Inflection.singularize(type)}_id")))

  strategyBudgetData: () ->
    return new Visio.Collections.Budget(Visio.manager.get('budgets').filter((d) =>
      return _.every Visio.Types, (type) =>
        return true if type == Visio.Parameters.INDICATORS
        if @name == type
          ids = [@id] if Visio.manager.strategy().include(type, @id)
        else if type == Visio.Parameters.OUTPUTS
          # Add undefined because budget data can have an undefined output
          ids = Visio.manager.strategy().get("#{type}_ids").concat([undefined])
        else
          ids = Visio.manager.strategy().get("#{type}_ids")

        _.include ids, d.get("#{Inflection.singularize(type)}_id")))

  strategyBudget: () ->
    data = @strategyBudgetData()
    data.budget()

  toJSON: () ->
    json = _.clone(this.attributes)

    for attr, value of json
      if json[attr] instanceof Backbone.Model || json[attr] instanceof Backbone.Collection
        json[attr] = json[attr].toJSON()
    json

