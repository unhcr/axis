class Visio.Views.SliderView extends Backbone.View

  className: 'slider-container row'

  slideDelay: 20

  initialize: (options) ->
    @template = HAML["sliders/#{@name.singular}_slider"]
    @$el.addClass "#{@name.singular}-slider"
    @views = {}
    @position = 0
    @isPdf = options.isPdf

  events:
    'click .next': 'onNext'
    'click .previous': 'onPrevious'

  render: ->
    @$el.html @template({ collection: @collection, isPdf: @isPdf })

    @$el.find('.slider').addClass 'grid' if @isPdf
    @addAll()
    @

  drawFigures: ->
    console.warn 'drawFigures not implemented for this slider'

  addAll: =>
    @collection.each @addOne

  addOne: (model) =>
    opts =
      model: model
      className: "#{@name.singular}-slide slide"
      idx: @collection.indexOf model
      isPdf: @isPdf

    unless @views[model.id]?
      @views[model.id] = new Visio.Views["#{@name.className}SlideView"](opts)
    else
      @views[model.id].delegateEvents()
    @$el.find('.slider').append @views[model.id].render().el

  move: (toMove = 0) =>
    $slides = @$el.find ".#{@name.singular}-slide"
    slideWidth = $slides.outerWidth(true)

    len = $slides.length

    # new left
    @position += toMove
    if -@position >= $slides.length
      @position = -1 * ($slides.length + toMove)
    else if @position > 0
      @position = 0
    left = (@position * slideWidth)

    $slides.each (idx, ele) =>
      delay = if toMove < 0 then @slideDelay * idx else @slideDelay * (len - idx - 1)
      window.setTimeout  (->
        $(ele).css 'left', left + 'px'),
        delay

  onNext: (e) =>
    @move(-1)

  onPrevious: (e) =>
    @move(1)

  reset: =>
    @$el.find('.slide').css 'left', 0
    @position = 0

  close: =>
    for id, view of @views
      view.close()

    @unbind()
    @remove()
