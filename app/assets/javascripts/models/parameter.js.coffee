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
        id = d.get("#{Inflection.singularize(type)}_id")

        if @name == type
          return @id == id && Visio.manager.get('selected')[type][id]
        else
          return Visio.manager.get('selected')[type][id]))

  selectedBudgetData: () ->
    return new Visio.Collections.Budget(Visio.manager.get('budgets').filter((d) =>
      return _.every Visio.Types, (type) =>
        return true if type == Visio.Parameters.INDICATORS
        id = d.get("#{Inflection.singularize(type)}_id")

        if @name == type
          return @id == id && Visio.manager.get('selected')[type][id]
        else if type == Visio.Parameters.OUTPUTS
          return Visio.manager.get('selected')[type][id] || id == undefined
        else
          return Visio.manager.get('selected')[type][id] ))

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
        id = d.get("#{Inflection.singularize(type)}_id")

        if @name == type
          return id == @id && strategy.get("#{type}_ids")[id]
        else
          return strategy.get("#{type}_ids")[id] ))

  strategyBudgetData: (strategy) ->
    strategy ||= Visio.manager.strategy()

    return new Visio.Collections.Budget(Visio.manager.get('budgets').filter((d) =>
      return _.every Visio.Types, (type) =>
        return true if type == Visio.Parameters.INDICATORS
        id = d.get("#{Inflection.singularize(type)}_id")

        if @name == type
          return id == @id && strategy.get("#{type}_ids")[id]
        else if type == Visio.Parameters.OUTPUTS
          # Add undefined because budget data can have an undefined output
          return strategy.get("#{type}_ids")[id] || id == undefined
        else
          return strategy.get("#{type}_ids")[id] ))

  strategyBudget: () ->
    data = @strategyBudgetData()
    data.budget()

  toJSON: () ->
    json = _.clone(this.attributes)

    for attr, value of json
      if json[attr] instanceof Backbone.Model || json[attr] instanceof Backbone.Collection
        json[attr] = json[attr].toJSON()
    json

