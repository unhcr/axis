class Visio.Models.Parameter extends Visio.Models.Syncable

  selectedIndicatorData: () ->
    return new Visio.Collections.IndicatorDatum(Visio.manager.get('indicator_data').filter((d) =>
      return _.every _.values(Visio.Parameters), (hash) =>
        id = d.get("#{hash.singular}_id")

        if @name == hash.plural
          return @id == id && Visio.manager.get('selected')[hash.plural][id]
        else
          return Visio.manager.get('selected')[hash.plural][id]))

  selectedBudgetData: () ->
    return new Visio.Collections.Budget(Visio.manager.get('budgets').filter((d) =>
      return _.every _.values(Visio.Parameters), (hash) =>
        return true if hash.plural == Visio.Parameters.INDICATORS.plural
        id = d.get("#{hash.singular}_id")

        if @name == hash.plural
          return @id == id && Visio.manager.get('selected')[hash.plural][id]
        else if hash.plural == Visio.Parameters.OUTPUTS.plural
          return Visio.manager.get('selected')[hash.plural][id] || id == undefined
        else
          return Visio.manager.get('selected')[hash.plural][id] ))

  strategyIndicatorData: (strategy) ->
    strategy ||= Visio.manager.strategy()

    return new Visio.Collections.IndicatorDatum(Visio.manager.get('indicator_data').filter((d) =>
      return _.every _.values(Visio.Parameters), (hash) =>
        id = d.get("#{hash.singular}_id")

        if @name == hash.plural
          return id == @id && strategy.get("#{hash.singular}_ids")[id]
        else
          return strategy.get("#{hash.singular}_ids")[id] ))

  strategyBudgetData: (strategy) ->
    strategy ||= Visio.manager.strategy()

    return new Visio.Collections.Budget(Visio.manager.get('budgets').filter((d) =>
      return _.every _.values(Visio.Parameters), (hash) =>
        return true if hash.plural == Visio.Parameters.INDICATORS.plural
        id = d.get("#{hash.singular}_id")

        if @name == hash.plural
          return id == @id && strategy.get("#{hash.singular}_ids")[id]
        else if hash.plural == Visio.Parameters.OUTPUTS.plural
          # Add undefined because budget data can have an undefined output
          return strategy.get("#{hash.singular}_ids")[id] || id == undefined
        else
          return strategy.get("#{hash.singular}_ids")[id] ))

  strategyBudget: () ->
    data = @strategyBudgetData()
    data.budget()

  strategySituationAnalysis: () ->
    data = @strategyIndicatorData()
    data.situationAnalysis()

  selectedAchievement: () ->
    data = @selectedIndicatorData()
    data.achievement()

  selectedBudget: () ->
    data = @selectedBudgetData()
    data.budget()

  selectedSituationAnalysis: () ->
    data = @selectedIndicatorData()
    data.situationAnalysis()

