class Visio.Views.ParameterSliderView extends Visio.Views.SliderView

  name:
    singular: 'parameter'
    className: 'Parameter'

  events:
    'click .next': 'onNext'
    'click .previous': 'onPrevious'
    'mouseenter .parameter-slide': 'onMouseenter'
    'mouseout': 'onMouseout'

  initialize: (options) ->
    @filters = options.filters
    @isPdf = options.isPdf
    super options

  drawFigures: =>
    @collection.each (model) =>
      @views[model.id]?.drawFigures()

  addOne: (model) =>
    super model
    @views[model.id].filters = @filters


  toMove: (isNext) ->
    multiplier = if isNext then -1 else 1

    $slides = @$el.find(".#{@name.singular}-slide")

    slideWidth = $slides.outerWidth(true)
    sliderWidth = @$el.width()

    # How many we can show on the page
    toMove = Math.floor sliderWidth / slideWidth
    toMove * multiplier

  onNext: (e) =>
    @move(@toMove(true)) unless @$el.find('.slider').hasClass 'grid'

  onPrevious: (e) =>
    @move(@toMove(false)) unless @$el.find('.slider').hasClass 'grid'

  onMouseenter: (e) =>
     #@$el.find('.parameter-slide').css('opacity', .5)
     #$(e.currentTarget).css('opacity', 1)

  onMouseout: (e) =>
     #console.log 'out'
     #@$el.find('.parameter-slide').css('opacity', 1)
     #

