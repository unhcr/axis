class Visio.Figures.Base extends Backbone.View

  template: HAML['figures/base']

  attrAccessible: ['x', 'y', 'width', 'height', 'collection', 'margin', 'model']

  attrConfig: ['margin', 'width', 'height']

  viewLocation: 'Figures'

  initialize: (config) ->

    # default margin
    @margin =
      left: 2
      right: 2
      top: 2
      bottom: 2
    for attr, value of config
      @[attr] = value

    _.each @attrAccessible, (attr) =>
      @[attr + 'Fn'] = (_attr) =>
        return @[attr] unless arguments.length
        @[attr] = _attr
        @

    if config?.filters?
      @filters = new Visio.Collections.FigureFilter(config.filters)

    @template = HAML["pdf/#{@type.name}"] if @isPdf
    @$el.html @template({ figure: @, model: @model, collection: @collection, isExport: @isExport, exportable: @exportable })
    @selection = d3.select @$el.find('figure')[0]


    # Adjust for margins
    @adjustedWidth = (config.width - @margin.left - @margin.right)
    @adjustedHeight = (config.height - @margin.top - @margin.bottom)

    @svg = @selection.append('svg')
      .attr('width', config.width)
      .attr('height', config.height)
      .attr('class', "svg-#{@type.name}-figure")


    @g = @svg.append('g')
      .attr('transform', "translate(#{@margin.left}, #{@margin.top})")


    @subscribe() if config.isExport

  selectable: true

  close: ->
    @unbind()
    @remove()
