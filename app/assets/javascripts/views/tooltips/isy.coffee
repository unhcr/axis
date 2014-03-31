class Visio.Views.IsyTooltip extends Visio.Views.D3Tooltip

  name: 'isy'

  offset: 140

  width: => @figure.widthFn()

  height: -> 300

  top: =>
    @figure.$el.offset().top + 60

  left: =>
    $(@figure.el).offset().left

  initialize: (options) ->
    @figure = options?.figure
    @isyIndex = options?.isyIndex

    super options

  render: ->
    values = [
      { value: Visio.Algorithms.GOAL_TYPES.target, human: 'TARGET' },
      { value: Visio.Algorithms.GOAL_TYPES.compTarget, human: 'COMP TARGET' },
      { value: Visio.Algorithms.REPORTED_VALUES.yer, human: 'YER' },
      { value: Visio.Algorithms.REPORTED_VALUES.myr, human: 'MYR' },
      { value: Visio.Algorithms.REPORTED_VALUES.baseline, human: 'BASELINE' },
    ]
    values.push { value: 'standard', human: 'STANDARD' } if @model.get 'standard'

    @$el.html @template({ model: @model, values: values })

    super

    @
