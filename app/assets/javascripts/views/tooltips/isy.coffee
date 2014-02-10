class Visio.Views.IsyTooltip extends Visio.Views.D3Tooltip

  name: 'isy'

  offset: 140

  width: => ((2*@figure.widthFn() / 3) - @offset)

  height: -> 300

  top: =>
    @figure.$el.offset().top

  left: =>
    console.log @isyIndex
    base = $(@figure.el).offset().left + @figure.xFn()(@isyIndex) + @figure.marginFn().left
    if @figure.xFn()(@isyIndex) > @figure.widthFn() / 2
      return base - @offset - @width()
    else
      return base + @offset

  initialize: (options) ->
    @figure = options.figure
    @isyIndex = options.isyIndex

    Visio.Views.D3Tooltip.prototype.initialize.call @, options

  render: ->
    values = [
      { value: 'comp_target', human: 'TARGET' },
      { value: 'yer', human: 'YER' },
      { value: 'myr', human: 'MYR' },
      { value: 'baseline', human: 'BASELINE' },
    ]
    values.push { value: 'standard', human: 'STANDARD' } if @model.get 'standard'

    @$el.html @template({ model: @model, values: values })

    Visio.Views.D3Tooltip.prototype.render.call @

    @
