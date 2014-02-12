class Visio.Figures.Base extends Backbone.View

  attrAccessible: ['x', 'y', 'width', 'height', 'data', 'margin']

  initialize: (config) ->
    for attr, value of config
      @[attr] = value

    _.each @attrAccessible, (attr) =>
      @[attr + 'Fn'] = (_attr) =>
        return @[attr] unless arguments.length
        @[attr] = _attr
        @

    @selection = d3.select @el

    @originalWidth = config.width
    @originalHeight = config.height

    @svg = @selection.append('svg')
      .attr('width', config.width)
      .attr('height', config.height)
      .attr('class', "svg-#{@type.name}-figure")


    @g = @svg.append('g')
      .attr('transform', "translate(#{@margin.left}, #{@margin.top})")

