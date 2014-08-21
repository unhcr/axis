class Visio.Figures.Base extends Backbone.View

  template: HAML['figures/base']

  attrAccessible: ['x', 'y', 'width', 'height', 'collection', 'margin', 'model']

  attrConfig: ['margin', 'width', 'height']

  viewLocation: 'Figures'

  hasAxis: true

  initialize: (config, templateOpts) ->

    # default margin, config will override if applicable
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

    @template = HAML["figures/#{@type.name}"] if HAML["figures/#{@type.name}"]?

    if @isPdf and HAML["pdf/figures/#{@type.name}"]
      @template = HAML["pdf/figures/#{@type.name}"]
    else if @isPdf
      @template = HAML["pdf/figures/base"]

    opts =
      figure: @
      model: @model
      collection: @collection
      isExport: @isExport
      exportable: @exportable

    @$el.html @template(_.extend(opts, templateOpts))

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
