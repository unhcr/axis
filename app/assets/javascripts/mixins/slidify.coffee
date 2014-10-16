Visio.Mixins.Slidify =

  sliderClass: '.slider'

  initSlider: (figure) ->
    @sliderFigure = figure

    $.subscribe "hover.#{figure.cid}.figure", (e, idxOrDatum) =>
      if _.isNumber idxOrDatum
        value = idxOrDatum
      else
        value = figure.findBoxByDatum(idxOrDatum).idx

      @$el.find(@sliderClass).slider 'value', value
      @$el.find("#{@sliderClass} .ui-slider-handle").attr 'data-value', value + 1

  renderSlider: ->

    @$el.find(@sliderClass).slider
      animate: true
      slide: @onSlide.bind(@)
      stop: @onStop.bind(@)
      min: 0

  onStop: (e, ui) ->
    $.publish "mouseout.#{@sliderFigure.cid}.figure", ui.value

  onSlide: (e, ui) ->
    $.publish "hover.#{@sliderFigure.cid}.figure", ui.value
    @$el.find("#{@sliderClass} .ui-slider-handle").attr 'data-value', ui.value + 1

  setSliderMax: (max) ->
    @$el.find(@sliderClass).slider 'option', 'max', max - 1
    @$el.find(@sliderClass).attr 'data-max', max

  hideSlider: ->
    @$el.find(@sliderClass).addClass 'gone'

  showSlider: ->
    @$el.find(@sliderClass).removeClass 'gone'
