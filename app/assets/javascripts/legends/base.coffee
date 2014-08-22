class Visio.Legends.Base extends Backbone.View

  isPdf: false

  className: 'legend'

  initialize: ->
    @$el.addClass "legend-#{@type.name}"
    @$el.css 'width', Visio.Constants.LEGEND_WIDTH + 'px'
    if @isPdf
      @template = HAML["pdf/legends/#{@type.name}"]
    else
      @template = HAML["legends/#{@type.name}"]

    throw new Error('No legend template defined') unless @template?

  render: ->
    @$el.html @template()
    @
