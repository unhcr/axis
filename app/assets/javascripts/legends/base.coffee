class Visio.Legends.Base extends Backbone.View

  isPdf: false

  className: 'legend'

  initialize: ->
    @$el.addClass "legend-#{@type.name}"

    if @isPdf
      @template = HAML["pdf/legends/#{@type.name}"]
    else
      @$el.css 'width', Visio.Constants.LEGEND_WIDTH + 'px'
      @template = HAML["legends/#{@type.name}"]

    throw new Error('No legend template defined') unless @template?

  render: ->
    @$el.html @template { type: @type }

    @drawFigures?(@$el.find('svg')[0])
    @

  close: ->
    @unbind()
    @remove()
