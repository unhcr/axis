class Visio.Models.Manager extends Backbone.Model

  constructor: () ->
    @indicators = new Visio.Collections.Indicator()
    @outputs = new Visio.Collections.Output()
    @problemObjectives = new Visio.Collections.ProblemObjective()
    @ppgs = new Visio.Collections.Ppg()
