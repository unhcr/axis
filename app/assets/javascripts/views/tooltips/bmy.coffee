class Visio.Views.BmyTooltip extends Visio.Views.D3Tooltip

  name: 'bmy'

  offset: 30

  width: -> 180

  height: => @figure.heightFn()

  top: => $(@figure.el).offset().top

  left: =>
    base = $(@figure.el).offset().left + @figure.xFn()(@year) + @figure.marginFn().left
    if (_.indexOf @figure.xFn().domain(), @year) < @figure.xFn().domain().length - 1
      return base + @offset
    else
      # Last element in domain
      return base - @offset - @width()

  initialize: (options) ->
    @figure = options.figure
    @year = options.year

    Visio.Views.D3Tooltip.prototype.initialize.call @, options

  render: (isRerender) ->
    sortedModels = @collection.sortBy @sortBy

    @$el.html @template({ year: @year, sortedModels: sortedModels })

    Visio.Views.D3Tooltip.prototype.render.call @, isRerender

    @

  sortBy: (model) -> +model.get('amount') * -1
