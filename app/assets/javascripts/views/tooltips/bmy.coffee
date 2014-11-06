class Visio.Views.BmyTooltip extends Visio.Views.D3Tooltip

  name: 'bmy'

  offset: 30

  width: -> 195

  height: => @figure.heightFn()

  top: => @figure.$el.find('svg:first').offset().top - 80

  left: =>
    base = @figure.$el.find('svg:first').offset().left + @figure.xFn()(@year) + @figure.marginFn().left
    if (_.indexOf @figure.xFn().domain(), @year) < @figure.xFn().domain().length - 1
      return base + @offset + Visio.Constants.LEGEND_WIDTH
    else
      # Last element in domain
      return base - @offset - @width() + Visio.Constants.LEGEND_WIDTH

  initialize: (options) ->
    @figure = options.figure
    @year = options.year

    super options

  render: (isRerender) ->
    sortedModels = @collection.sortBy @sortBy

    @$el.html @template({ year: @year, sortedModels: sortedModels })

    super isRerender

    @

  sortBy: (model) -> +model.get('amount') * -1
