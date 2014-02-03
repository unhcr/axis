class Visio.Views.IsyTooltip extends Visio.Views.D3Tooltip

  name: 'isy'

  offset: 170

  width: => ((2*@figure.width() / 3) - @offset) + 'px'

  height: -> '300px'

  top: =>
    @$figureEl.offset().top

  left: =>
    if @figure.x()(@isyIndex) > @figure.width() / 2
      return @$figureEl.offset().left - @width() - @offset
    else
      return @$figureEl.offset().left + @offset

  initialize: (options) ->
    @figure = options.figure
    @$figureEl = options.$figureEl
    @isyIndex = options.index

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
