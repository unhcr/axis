class Visio.Models.Parameter extends Visio.Models.Syncable

  selectedData: (type) ->
    return new Visio.Collections[type.className](Visio.manager.get(type.plural).filter((d) =>
      return _.every _.values(Visio.Parameters), (hash) =>
        return true if hash.plural == Visio.Parameters.STRATEGY_OBJECTIVES.plural

        # Skip indicator if it's a budget
        if type.plural == Visio.Syncables.BUDGETS.plural
          return true if hash.plural == Visio.Parameters.INDICATORS.plural
        id = d.get("#{hash.singular}_id")

        isSelected = Visio.manager.get('selected')[hash.plural][id]

        if @name == hash.plural
          return @id == id and isSelected
        else if hash.plural == Visio.Parameters.OUTPUTS.plural
          return isSelected or not id?
        else
          return isSelected ))

  selectedIndicatorData: () ->
    @selectedData(Visio.Syncables.INDICATOR_DATA)

  selectedBudgetData: () ->
    @selectedData(Visio.Syncables.BUDGETS)

  strategyData: (type, strategy) ->
    strategy or= Visio.manager.strategy()

    return new Visio.Collections[type.className](Visio.manager.get(type.plural).filter((d) =>
      return _.every _.values(Visio.Parameters), (hash) =>
        return true if hash.plural == Visio.Parameters.STRATEGY_OBJECTIVES.plural
        # Skip indicator if it's a budget
        if type.plural == Visio.Syncables.BUDGETS.plural
          return true if hash.plural == Visio.Parameters.INDICATORS.plural

        id = d.get("#{hash.singular}_id")

        isSelected = strategy.get("#{hash.singular}_ids")[id]

        if @name == hash.plural
          return id == @id && isSelected
        else if hash.plural == Visio.Parameters.OUTPUTS.plural
          # Add null/undefined because budget data can have an undefined output
          return isSelected or not id?
        else
          return isSelected ))

  strategyIndicatorData: (strategy) ->
    @strategyData(Visio.Syncables.INDICATOR_DATA, strategy)

  strategyBudgetData: (strategy) ->
    @strategyData(Visio.Syncables.BUDGETS, strategy)

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

