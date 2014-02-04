class Visio.Views.BmyTooltip extends Visio.Views.D3Tooltip

  name: 'bmy'

  offset: 30

  width: -> 180

  height: => @figure.height()

  top: => $(@figure.el()).offset().top

  left: =>
    base = $(@figure.el()).offset().left + @figure.x()(@year) + @figure.margin().left
    if (_.indexOf @figure.x().domain(), @year) < @figure.x().domain().length - 1
      base + @offset
    else
      # Last element in domain
      base - @offset - @width()

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
