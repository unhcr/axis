class Visio.Views.IsyTooltip extends Backbone.View

  name: 'isy'

  template: HAML['tooltips/isy']

  initialize: (options) ->
    @figure = options?.figure
    @rendered = false

    super options

  render: (d) ->
    return unless d?
    @rendered = true
    values = [
      { value: Visio.Algorithms.GOAL_TYPES.target, human: 'TARGET' },
      { value: Visio.Algorithms.GOAL_TYPES.compTarget, human: 'COMP TARGET' },
      { value: Visio.Algorithms.GOAL_TYPES.standard, human: 'STANDARD' }
      { value: Visio.Algorithms.REPORTED_VALUES.yer, human: 'YER' },
      { value: Visio.Algorithms.REPORTED_VALUES.myr, human: 'MYR' },
      { value: Visio.Algorithms.REPORTED_VALUES.baseline, human: 'BASELINE' },
    ]

    @$el.html @template({ d: d, values: values })

    @

  hasRendered: =>
    @rendered

  close: =>
    @remove()
    @unbind()
