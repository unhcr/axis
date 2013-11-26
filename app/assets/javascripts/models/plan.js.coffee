class Visio.Models.Plan extends Visio.Models.Parameter

  initialize: (attrs, options) ->
    @set(
      indicators: new Visio.Collections.Indicator()
      outputs: new Visio.Collections.Output()
      problem_objectives: new Visio.Collections.ProblemObjective()
      ppgs: new Visio.Collections.Ppg()
      goals: new Visio.Collections.Goal()
    )

  name: Visio.Parameters.PLANS

  urlRoot: '/plans'

  paramRoot: 'plan'

  fetchIndicators: () ->
    @fetchParameter(Visio.Parameters.INDICATORS)

  fetchParameter: (type) ->

    $.get("#{@urlRoot}/#{@id}/#{type}"
    ).then((parameters) =>
      @get(type).reset(parameters)

      @setSynced()
    )

  toJSON: () ->
    json = _.clone(this.attributes)

    for attr, value of json
      if json[attr] instanceof Backbone.Model || json[attr] instanceof Backbone.Collection
        json[attr] = json[attr].toJSON()
    json


