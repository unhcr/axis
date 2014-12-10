# This class is the parent class for all figures.
class Visio.Figures.Base extends Backbone.View

  template: HAML['figures/base']

  templateLabel: HAML['figures/label']

  # Any attribute listed here will have an accessor function made for it. The width attribute's accessor will
  # be called widthFn. The other attributes follow the same pattern.
  attrAccessible: ['x', 'y', 'width', 'height', 'collection', 'margin', 'model']

  # Determines which attributes should be exported when calling 'config'. Used for exporting figures.
  attrConfig: ['margin', 'width', 'height']

  # Where to find the view. Ex: Visio[viewLocation][<viewName>]
  viewLocation: 'Figures'

  hasAxis: true

  initialize: (config, templateOpts) ->

    # default margin, config will override if applicable
    @margin =
      left: 2
      right: 2
      top: 2
      bottom: 2

    # Every attribute in config becomes a property of the figure by default
    for attr, value of config
      @[attr] = value

    # Create accessor functions
    _.each @attrAccessible, (attr) =>
      @[attr + 'Fn'] = (_attr) =>
        return @[attr] unless arguments.length
        @[attr] = _attr
        @

    if config?.filters?
      @filters = new Visio.Collections.FigureFilter(config.filters)

    # Logic for selecting template. If no specific template is defined for that figure, it uses the base
    # template
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

    # Selected data for the figure. If it's "selectable" then you can read narratives on it.
    if Visio.SelectedData[@type.className]?
      @selectedDatum = new Visio.SelectedData[@type.className]({ d: null })
    else
      @selectedDatum = new Visio.SelectedData.Base({ d: null })

    legendClass = if @isPdf then "#{@type.className}Pdf" else @type.className

    @legendView = new Visio.Legends[legendClass]?({ figure: @ })

    # The selection for the svg to be append to
    @selection = d3.select @$el.find('figure')[0]

    # Adjust for margins
    @adjustedWidth = (config.width - @margin.left - @margin.right)
    @adjustedHeight = (config.height - @margin.top - @margin.bottom)

    if @isExport
      @adjustedHeight -= Visio.Constants.EXPORT_LABELS_HEIGHT
      @adjustedWidth -= Visio.Constants.EXPORT_LEGEND_WIDTH

    @svg = @selection.append('svg')
      .attr('width', config.width)
      .attr('height', config.height)
      .attr('class', "svg-#{@type.name}-figure")


    @g = @svg.append('g')
      .attr('transform', "translate(#{@margin.left}, #{@margin.top})")

    # gLabels, used for PNG exports
    if @isExport
      @nCols = 2
      @yGLegend = d3.scale.linear()
        .domain([0, 10])
        .range([0, Visio.Constants.EXPORT_LABELS_HEIGHT])
      @xGLegend = d3.scale.ordinal()
        .domain(_.range(@nCols + 1))
        .rangePoints([-@margin.left, Visio.Constants.EXPORT_WIDTH - @margin.right], 0.2)
      @gLabels = @svg.append('g')
        .attr('transform', "translate(#{@margin.left}, #{@margin.top + @adjustedHeight + @margin.bottom})")
        .attr('class', "svg-#{@type.name}-labels svg-labels")
      @activeData = new Backbone.Collection()

    if @isPdf
      @activeData = new Backbone.Collection(config.activeData)

    @subscribe() if config.isExport

  # Can the figure be selectable in export mode
  selectable: true

  # Selects an element for export view
  select: (d, i) =>

    if @activeData.get(@datumId(d))?
      @activeData.remove @datumId(d)
    else
      @activeData.add { id: @datumId(d), d: d }

  renderLegend: =>
    if @isExport
      @renderSvgLegend()
    else
      @$el.find('.legend-container').html @legendView?.render().el

  # Used for PNG exports since html cannot easily be converted to PNG
  renderSvgLegend: =>

    svgLegend = @g.append('svg')
      .attr('x', @margin.left + @adjustedWidth)
      .attr('width', Visio.Constants.EXPORT_LEGEND_WIDTH)
      .attr('height', @adjustedHeight)
      .attr('class', "legend-#{@type.name}")
    @legendView?.drawFigures?(svgLegend.node())

  # Used for PNG exports since html cannot easily be converted to PNG
  renderSvgLabels: =>

    gLabelPadding = 30
    wrapWidth = (@xGLegend.range()[1] - @xGLegend.range()[0]) - gLabelPadding

    gLabels = @gLabels.selectAll('.g-label').data @activeData.models
    gLabels.enter().append('text')
    gLabels
      .attr('class', 'g-label')
      .attr('text-anchor', 'start')
      .attr('dy', '-.33em')
      .attr('x', (d, i) =>
        col = Math.floor(i / @yGLegend.domain()[1])
        gLabelPadding + @xGLegend col
      )
      .attr('y', (d, i) => @yGLegend(i % @yGLegend.domain()[1]))
      .text((m) => @datumToString(m.get('d')))
      .call @wrap, wrapWidth

    gLabels.exit().remove()

    gLabelTexts = @gLabels.selectAll('.g-label-index').data @activeData.models
    gLabelTexts.enter().append('text')
    gLabelTexts
      .attr('class', (d) => ['g-label-index', @datumClass(d)].join(' '))
      .attr('text-anchor', 'start')
      .attr('dy', '-.33em')
      .attr('x', (d, i) =>
        col = Math.floor(i / @yGLegend.domain()[1])
        10 + @xGLegend col
      )
      .attr('y', (d, i) => @yGLegend(i % @yGLegend.domain()[1]))
      .text (m, i) =>
        @selectableLabel m, i

    gLabelTexts.exit().remove()

    @graphLabels()

  # Sets the tooltips for the header buttons on the figure
  tipsyHeaderBtns: =>
    tipsyOpts =
      className: 'tipsy-black'
      trigger: 'hover'
      offset: 30

    $narrative = @$el.find('.narrative')
    $narrative.attr 'original-title', Visio.TooltipTexts.TOOLBAR_NARRATIVE if $narrative
    $narrative.tipsy tipsyOpts

    $exp = @$el.find('.export')
    $exp.attr 'original-title', Visio.TooltipTexts.TOOLBAR_EXPORT if $exp
    $exp.tipsy tipsyOpts

    $sortBy = @$el.find('.sort-by')
    $sortBy.attr 'original-title', Visio.TooltipTexts.TOOLBAR_SORT_BY if $sortBy
    $sortBy.tipsy tipsyOpts

    $filterBy = @$el.find('.filter-by')
    $filterBy.attr 'original-title', Visio.TooltipTexts.TOOLBAR_FILTER_BY if $filterBy
    $filterBy.tipsy tipsyOpts

  graphLabels: =>

  datumClass: ->

  datumId: (d) =>
    d.id

  datumToString: (d) =>
    d.toString()

  getPNGSvg: =>
    @$el.find('svg')

  # Utility for wrapping svg text
  wrap: (text, width) =>
    text.each ->
      text = d3.select @
      fontSize = +window.getComputedStyle(text.node(), null).getPropertyValue('font-size').replace('px', '')
      words = text.text().split(/\s+/).reverse()
      line = []
      lineNumber = 0
      padding = 2
      y = +text.attr("y")
      x = +text.attr("x")
      dy = parseFloat(text.attr("dy"))
      tspan = text.text(null).append("tspan").attr("x", x).attr("y", y).attr("dy", dy + "em")

      while word = words.pop()
        line.push(word)
        tspan.text(line.join(" "))
        if tspan.node().getComputedTextLength() > width
          line.pop()
          tspan.text(line.join(" "))
          line = [word]
          lineNumber += 1
          tspan = text.append("tspan")
            .attr("x", x).attr("y", y + (lineNumber * (fontSize + padding)))
            .attr("dy", dy + "em").text(word)

  # Closes figure. Should always be called to remove the figure since it unbinds and properly deconstructs the
  # object.
  close: ->
    @selectedDatum.off()
    @legendView?.close()

    # remove any tipsy elements
    $('.tipsy').remove()
    @unbind()
    @remove()
