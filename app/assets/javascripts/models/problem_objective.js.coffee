class Visio.Models.ProblemObjective extends Visio.Models.Parameter

  urlRoot: '/problem_objectives'

  paramRoot: 'problem_objective'

  toString: () ->
    return @get('objective_name')

  name: Visio.Parameters.PROBLEM_OBJECTIVES.plural
