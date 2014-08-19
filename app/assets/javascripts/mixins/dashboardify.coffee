# Utilities for all dashboard models
Visio.Mixins.Dashboardify =

  indicators: ->
    @parameters Visio.Parameters.INDICATORS
  outputs: ->
    @parameters Visio.Parameters.OUTPUTS
  problem_objectives: ->
    @parameters Visio.Parameters.PROBLEM_OBJECTIVES
  goals: ->
    @parameters Visio.Parameters.GOALS
  ppgs: ->
    @parameters Visio.Parameters.PPGS
  operations: ->
    @parameters Visio.Parameters.OPERATIONS

  parameters: (hash) ->
    ids = _.keys(@get("#{hash.singular}_ids"))
    parameters = Visio.manager.get(hash.plural)
    return new parameters.constructor(parameters.filter (model) =>
      @get("#{hash.singular}_ids")[model.id])

  # Returns true when the strategy is shareable, false otherwise
  shareable: ->
    return false unless Visio.manager.get('dashboard') instanceof Visio.Models.Strategy

    return true if Visio.manager.isDashboardPersonal()

    false


