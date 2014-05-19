class Visio.Views.SliderView extends Backbone.View

  className: 'slider-container row'

  slideDelay: 20

  perPage: 5

  page: 0

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

    @page = 0
    @addPage @page
    @page += 1

    @

  drawFigures: ->
    console.warn 'drawFigures not implemented for this slider'

  addAll: =>
    @collection.each @addOne

  addPage: (page) =>
    start = page * @perPage
    end = (page + 1) * @perPage

    _.each @collection.models[start..end], @addOne

  addOne: (model) =>
    opts =
      model: model
      className: "#{@name.singular}-slide slide"
      idx: @collection.indexOf model
      isPdf: @isPdf

    if @views[model.id]?
      @views[model.id].delegateEvents()
    else
      @views[model.id] = new Visio.Views["#{@name.className}SlideView"](opts)
    @$el.find('.slider').append @views[model.id].render().el

  move: (toMove = 0) =>
    $slides = @$el.find ".#{@name.singular}-slide"
    slideWidth = $slides.outerWidth(true)

    len = $slides.length

    # new left
    @position += toMove

    if Math.abs(@position) + @perPage >= @page * @perPage
      @addPage @page
      @page += 1

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
    @move -1

  onPrevious: (e) =>
    @move 1

  reset: =>
    @$el.find('.slide').css 'left', 0
    @position = 0

  close: =>
    for id, view of @views
      view.close()

    @unbind()
    @remove()
