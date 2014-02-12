class Visio.Views.CountrySliderView extends Backbone.View

  template: HAML['shared/country_slider']

  className: 'country-slider'

  initialize: ->
    @views = {}
    @position = 0

  events:
    'click .next': 'onNext'
    'click .previous': 'onPrevious'
    'mouseenter .country-slide': 'onMouseenter'
    'mouseout': 'onMouseout'

  render: ->
    @$el.html @template({ operations: @collection })
    @addAll()
    @

  addAll: =>
    @collection.each @addOne

  addOne: (operation) =>
    return unless operation.get('country')?
    @views[operation.id] = new Visio.Views.CountrySlideView({ model: operation })
    @$el.find('.slider').append @views[operation.id].render().el

  onNext: (e) =>
    @move(true)

   move: (isNext) =>
    multiplier = if isNext then -1 else 1

    $slides = @$el.find('.country-slide')

    slideWidth = $slides.outerWidth(true)
    sliderWidth = @$el.width()

    # How many we can show on the page
    toMove = Math.floor sliderWidth / slideWidth

    len = $slides.length

    # new left
    @position += (multiplier * toMove)
    if isNext and -@position >= $slides.length - toMove
      @position = -1 * ($slides.length - toMove)
    else if not isNext and @position > 0
      @position = 0
    left = (@position * slideWidth)

    $slides.each (idx, ele) =>
      delay = if isNext then 50 * idx else 50 * (len - idx - 1)
      window.setTimeout  (->
        $(ele).css 'left', left + 'px'),
        delay

   onPrevious: (e) =>
     @move(false)

   onMouseenter: (e) =>
     #@$el.find('.country-slide').css('opacity', .5)
     #$(e.currentTarget).css('opacity', 1)

   onMouseout: (e) =>
     #console.log 'out'
     #@$el.find('.country-slide').css('opacity', 1)
