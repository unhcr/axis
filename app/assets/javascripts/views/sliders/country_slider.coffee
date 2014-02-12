class Visio.Views.CountrySliderView extends Visio.Views.SliderView

  name:
    singular: 'country'
    className: 'Country'

  events:
    'click .next': 'onNext'
    'click .previous': 'onPrevious'
    'mouseenter .country-slide': 'onMouseenter'
    'mouseout': 'onMouseout'

  addOne: (model) =>
    return unless model.get('country')?
    Visio.Views.SliderView.prototype.addOne.call @, model

  toMove: (isNext) ->
    multiplier = if isNext then -1 else 1

    $slides = @$el.find(".#{@name.singular}-slide")

    slideWidth = $slides.outerWidth(true)
    sliderWidth = @$el.width()

    # How many we can show on the page
    toMove = Math.floor sliderWidth / slideWidth
    toMove * multiplier

  onNext: (e) =>
    @move(@toMove(true))

  onPrevious: (e) =>
    @move(@toMove(false))

  onMouseenter: (e) =>
     #@$el.find('.country-slide').css('opacity', .5)
     #$(e.currentTarget).css('opacity', 1)

  onMouseout: (e) =>
     #console.log 'out'
     #@$el.find('.country-slide').css('opacity', 1)
     #

