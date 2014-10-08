class Visio.Models.Operation extends Visio.Models.Parameter

  urlRoot: '/operations'

  paramRoot: 'operation'

  name: Visio.Parameters.OPERATIONS

  populations: (ids, year, filters) ->

    populations = @get 'populations'

    _.reduce populations, ((sum, p) ->
      if ids[p.ppg_id]? and p.year == year then sum + p.value else sum )
    , 0

  selectedPopulation: (year, filters = null) ->
    year or= Visio.manager.year()

    idHash = Visio.manager.get('selected')[Visio.Parameters.PPGS.name]

    @populations idHash, year, filters

