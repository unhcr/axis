class Visio.Views.IcmyTooltip extends Visio.Views.D3Tooltip

  name: 'icmy'

  offset: 30

  width: -> 180

  height: => @figure.heightFn()

  top: => @figure.$el.find('svg:first').offset().top + 20

  left: =>
    base = @figure.$el.find('svg:first').offset().left + @figure.xFn()(@year) + @figure.marginFn().left
    if (_.indexOf @figure.xFn().domain(), @year) < @figure.xFn().domain().length - 1
      return base + @offset
    else
      # Last element in domain
      return base - @offset - @width()

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

