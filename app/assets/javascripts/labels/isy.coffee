class Visio.Labels.Isy extends Backbone.View

  template: HAML['labels/isy']

  params: [
    Visio.Parameters.OPERATIONS,
    Visio.Parameters.PPGS,
    Visio.Parameters.GOALS,
    Visio.Parameters.PROBLEM_OBJECTIVES,
    Visio.Parameters.OUTPUTS,
    Visio.Parameters.INDICATORS,
  ]

  render: (d) ->
    @$el.html @template
      d: d
      params: @params

    @

  close: ->
    @unbind()
    @remove()
