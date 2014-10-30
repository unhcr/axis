class Visio.Models.Parameter extends Visio.Models.Syncable

  @include Visio.Mixins.Dashboardify

  # @param: type - This is hash of the type of data we want (Budget, Expenditure, IndicatorDatum)
  # @param: idHash - This is a hash of ids that the data should include
  # @param: year - Allows for any specified year or false which will use all years. If undefined, will fall
  # @param: filters - Any sort of FigureFilter that should be applied to data
  # back to current year
  # @param: opts
  #   includeExternalStrategyData - Should we include external data
  #   strategyObjectiveIds - List of all strategy objective ids
  data: (type, idHash, year, filters, opts = {}) ->
    year = Visio.manager.year() unless year?


    # Return empty collection since indicators do not have budgets or expenditures
    if (type.plural == Visio.Syncables.BUDGETS.plural or
       type.plural == Visio.Syncables.EXPENDITURES.plural) and
       @name == Visio.Parameters.INDICATORS
      return new Visio.Collections[type.className]()

    # First pass at filtering
    if @name == Visio.Parameters.STRATEGY_OBJECTIVES
      # If it's not included in any of the SOs, throw it out
      data = Visio.manager.get(type.plural).filter (d) =>
        ids = d.get "#{@name.singular}_ids"

        _.include(ids, @id) or
          (_.every(ids, (id) -> _.indexOf(opts.strategyObjectiveIds, id) == -1) and
           opts.includeExternalStrategyData and
           @id == Visio.Constants.ANY_STRATEGY_OBJECTIVE and
           idHash[@name.plural][@id])
    else
      # data must have the instance's id
      condition = {}
      condition["#{@name.singular}_id"] = @id
      data = Visio.manager.get(type.plural).where(condition)

    data = _.filter data, (d) => not filters? or not filters.isFiltered(d)

    data = _.filter data, (d) =>
      return _.every _.values(Visio.Parameters), (hash) =>

        # This check is because it has already been filtered above
        return true if @name.plural == hash.plural

        # Must be current year if we are specifying year
        return false if year != Visio.Constants.ANY_YEAR and year != d.get('year')

        # Skip indicator if it's a budget
        if (type.plural == Visio.Syncables.BUDGETS.plural or
           type.plural == Visio.Syncables.EXPENDITURES.plural) and
           hash.plural == Visio.Parameters.INDICATORS.plural
          return true


        # One of strategy objective ids must be selected
        if hash == Visio.Parameters.STRATEGY_OBJECTIVES
          ids = d.get("#{hash.singular}_ids")

          # If any of the SO ids are selected, it's true
          result = _.any ids, (id) -> idHash[hash.plural][id]

          return true if result

          if opts.includeExternalStrategyData and idHash[hash.plural][Visio.Constants.ANY_STRATEGY_OBJECTIVE]
            return true if _.isEmpty(ids)

            # If it's not empty we need make sure that the ids it does have are not listed
            if opts.strategyObjectiveIds
              return true if _.every ids, (id) -> _.indexOf(opts.strategyObjectiveIds, id) == -1

          return false


        id = d.get("#{hash.singular}_id")

        # If output_id is missing that's ok
        return true if not id? and hash == Visio.Parameters.OUTPUTS


        idHash[hash.plural][id]

    return new Visio.Collections[type.className](data)

  populationData: (idHash, year, filters) ->
    year = Visio.manager.year() unless year?

    populations = Visio.manager.get 'populations'

    populations = populations.filter (p) =>
      p.get('element_type') == @name.plural and
        @id == p.get('element_id') and
        idHash.ppgs[p.get('ppg_id')] and
        (p.get('year') == year or year == Visio.Constants.ANY_YEAR)

    return new Visio.Collections.Population(populations)

  selectedIndicatorData: (year, filters = null) ->
    @selectedData(Visio.Syncables.INDICATOR_DATA, year, filters)

  selectedBudgetData: (year, filters = null) ->
    @selectedData(Visio.Syncables.BUDGETS, year, filters)

  selectedExpenditureData: (year, filters = null) ->
    @selectedData(Visio.Syncables.EXPENDITURES, year, filters)

  selectedPopulationData: (year, filters = null) ->
    selected = Visio.manager.get('selected')
    @populationData selected, year, filters

  selectedData: (type, year, filters = null) ->
    opts =
      includeExternalStrategyData: Visio.manager.includeExternalStrategyData()
      strategyObjectiveIds: Visio.manager.get('strategy_objectives').pluck('id')

    @data type, Visio.manager.get('selected'), year, filters, opts

  strategyData: (type, strategy, year, filters = null) ->
    strategy or= Visio.manager.strategy()
    idHash = {}
    opts =
      includeExternalStrategyData: Visio.manager.includeExternalStrategyData()

    _.each _.values(Visio.Parameters), (hash) ->
      idHash[hash.plural] = strategy.get("#{hash.singular}_ids")

    @data type, idHash, year, filters, opts


  strategyIndicatorData: (strategy, year, filters = null) ->
    @strategyData(Visio.Syncables.INDICATOR_DATA, strategy, year, filters)

  strategyBudgetData: (strategy, year, filters = null) ->
    @strategyData(Visio.Syncables.BUDGETS, strategy, year, filters)

  strategyExpenditureData: (strategy, year, filters = null) ->
    @strategyData(Visio.Syncables.EXPENDITURES, strategy, year, filters)

  strategyExpenditure: (year, filters = null) ->
    data = @strategyExpenditureData(null, year, filters)
    data.amount()

  strategyBudget: (year, filters = null) ->
    data = @strategyBudgetData(null, year, filters)
    data.amount()

  strategySituationAnalysis: () ->
    data = @strategyIndicatorData()
    data.situationAnalysis()

  strategyAchievement: (year, filters = null) ->
    data = @strategyIndicatorData(null, year, filters)
    data.achievement()

  strategyOutputAchievement: (year, filters = null) ->
    data = @strategyIndicatorData(null, year, filters)
    data.outputAchievement()

  # If it's a number indicator sum all data associated
  selectedIndicatorSum: (year, filters = null) ->
    console.warn 'Warning, using outside of indicator dashboard' unless Visio.manager.get('indicator')

    null unless Visio.manager.get('indicator')?.isNumber()

    data = @selectedIndicatorData year, filters
    data.sum()

  selectedOutputAchievement: (year, filters = null) ->
    data = @selectedIndicatorData year, filters
    data.outputAchievement()

  selectedAchievement: (year, filters = null) ->
    data = @selectedIndicatorData(year, filters)
    data.achievement()

  selectedPerformanceAchievement: (year, filters = null) ->
    filters or= new Visio.Collections.FigureFilter()
    filters.add { id: 'is_performance', filterType: 'radio', values: { true: true, false: false } },
        { merge: true }

    @selectedAchievement year, filters

  selectedImpactAchievement: (year, filters = null) ->
    filters or= new Visio.Collections.FigureFilter()
    filters.add { id: 'is_performance', filterType: 'radio', values: { true: false, false: true } },
        { merge: true }

    @selectedAchievement year, filters

  selectedBudget: (year, filters = null) ->
    data = @selectedBudgetData(year, filters)
    data.amount()

  selectedBudgetPerBeneficiary: (year, filters = null) ->
    data = @selectedBudgetData(year, filters)
    pData = @selectedPopulationData(year, filters)
    v = data.amount() / pData.amount()
    if _.isFinite(v) then v else 0

  selectedExpenditurePerBeneficiary: (year, filters = null) ->
    data = @selectedExpenditureData(year, filters)
    pData = @selectedPopulationData(year, filters)
    v data.amount() / pData.amount()
    if _.isFinite(v) then v else 0

  selectedPopulation: (year, filters = null) ->
    data = @selectedPopulationData(year, filters)
    data.amount()

  selectedSituationAnalysis: (year, filters = null) ->
    data = @selectedIndicatorData(year, filters)
    data.situationAnalysis()

  selectedExpenditure: (year, filters = null) ->
    data = @selectedExpenditureData(year, filters)
    data.amount()

  selectedExpenditureRate: (year, filters = null) ->
    expenditures = @selectedExpenditureData(year, filters)
    budgets = @selectedBudgetData(year, filters)
    expenditures.amount() / budgets.amount()

  refId: ->
    @id

  search: (query) ->
    $.get("#{@url}/search", { query: query })

  include: (singular, id) ->
    id == @id or @get("#{singular}_ids")?[id]?

  selectedAmount: (year, filters = null) ->
    # Either Budget or Expenditure
    @["selected#{Visio.manager.get('amount_type').className}"](year, filters)

  highlight: ->
    return @get('highlight').name[0] if @get('highlight')

