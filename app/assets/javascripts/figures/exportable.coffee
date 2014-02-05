class Visio.Figures.Exportable extends Backbone.View

  attrAccessible: ['x', 'y', 'width', 'height', 'figureId', 'exportId', 'data', 'margin']

  initialize: (config) ->

    for attr, value of config
      @[attr] = value

    _.each @attrAccessible, (attr) =>
      @[attr + 'Fn'] = (_attr) =>
        return @[attr] unless arguments.length
        @[attr] = _attr
        @

    @selection = d3.select @el

    # Adjust for margins
    @widthFn(config.width - @margin.left - @margin.right)
    @heightFn(config.height - @margin.top - @margin.bottom)

    @svg = @selection.append('svg')
      .attr('width', config.width)
      .attr('height', config.height)
      .attr('class', "svg-#{@type.name}-figure")

    @g = @svg.append('g')
      .attr('transform', "translate(#{@margin.left}, #{@margin.top})")

    $.subscribe "select.#{@cid}.figure", @select


  config: =>
    config = {}

    _.each @attrAccessible, (attr) =>
      config = @["_#{attr}"]

    config

  unsubscribe: => $.unsubscribe "select.#{@cid}.figure"

  select: (e, d, i) -> console.error('No select implemented')

  filtered: (data) -> data

  figureId: -> @cid
