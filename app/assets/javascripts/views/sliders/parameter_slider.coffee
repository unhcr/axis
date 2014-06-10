class Visio.Views.ParameterSliderView extends Visio.Views.SliderView

  name:
    singular: 'parameter'
    className: 'Parameter'

  events:
    'click .next': 'onNext'
    'click .previous': 'onPrevious'
    'click .show-more': 'onShowMore'

  initialize: (options) ->
    @filters = options.filters
    @isPdf = options.isPdf
    super options

  drawFigures: =>
    for id, view of @views
      if @collection.get id
        @views[id]?.drawFigures()
      else
        @views[id]?.close()
        delete @views[id]

  addOne: (model) =>
    super model
    @views[model.id].filters = @filters


  toMove: (isNext) ->
    multiplier = if isNext then -1 else 1

    $slides = @$el.find(".#{@name.singular}-slide")

    slideWidth = $slides.outerWidth true
    sliderWidth = @$el.width()

    # How many we can show on the page
    toMove = Math.floor sliderWidth / slideWidth
    toMove * multiplier

  onNext: (e) =>
    @move(@toMove(true)) unless @isGrid()

  onPrevious: (e) =>
    @move(@toMove(false)) unless @isGrid()

  onShowMore: (e) =>
    $target = $ e.currentTarget
    return if not @isGrid() or $target.hasClass('disabled')

    @addPage @page
    @page += 1

    if (@collection.length / @perPage) <= @page
      $target.addClass 'disabled'


