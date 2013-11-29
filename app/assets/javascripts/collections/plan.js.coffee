class Visio.Collections.Plan extends Visio.Collections.Parameter

  model: Visio.Models.Plan

  name: Visio.Parameters.PLANS

  url: '/plans'

  fetchSynced: (options) ->
    options ||= {}
    options.year ||= Visio.manager.year()

    Visio.Collections.Parameter.prototype.fetchSynced.call(@, options)
