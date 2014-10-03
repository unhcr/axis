class Visio.Figures.Base extends Backbone.View

  template: HAML['figures/base']

  templateLabel: HAML['figures/label']

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

    if Visio.SelectedData[@type.className]?
      @selectedDatum = new Visio.SelectedData[@type.className]({ d: null })
    else
      @selectedDatum = new Visio.SelectedData.Base({ d: null })

    @selection = d3.select @$el.find('figure')[0]

    $narrative = @$el.find('.narrative')
    $narrative.attr 'original-title', HAML['tooltips/info']({ text: 'Narrative' }) if $narrative
    $narrative.tipsy
      className: 'tipsy-black'
      trigger: 'hover'
      offset: 30

    $exp = @$el.find('.export')
    $exp.attr 'original-title', HAML['tooltips/info']({ text: 'Export' }) if $exp
    $exp.tipsy
      className: 'tipsy-black'
      trigger: 'hover'
      offset: 30


    # Adjust for margins
    @adjustedWidth = (config.width - @margin.left - @margin.right)
    @adjustedHeight = (config.height - @margin.top - @margin.bottom)

    if @isExport
      @adjustedWidth -= Visio.Constants.EXPORT_LEGEND_WIDTH

    @svg = @selection.append('svg')
      .attr('width', config.width)
      .attr('height', config.height)
      .attr('class', "svg-#{@type.name}-figure")


    @g = @svg.append('g')
      .attr('transform', "translate(#{@margin.left}, #{@margin.top})")

    # gLegend, used for PNG exports
    if @isExport
      @yGLegend = d3.scale.linear()
        .domain([0, 10])
        .range([0, Visio.Constants.EXPORT_HEIGHT])
      @gLegend = @svg.append('g')
        .attr('transform', "translate(#{@adjustedWidth + @margin.left}, #{@margin.top})")
        .attr('class', "svg-#{@type.name}-legend svg-legend")
      @gLegendData = new Backbone.Collection()

    @subscribe() if config.isExport

  selectable: true

  renderSvgLegend: (d, i) =>

    if @gLegendData.get(@datumId(d))?
      @gLegendData.remove @datumId(d)
    else
      label = @selectableLabel d, i
      @gLegendData.add { id: @datumId(d), d: d, label: label }

    gLegends = @gLegend.selectAll('.g-legend').data @gLegendData.models
    gLegends.enter().append('text')
    gLegends
      .attr('class', 'g-legend')
      .attr('text-anchor', 'start')
      .attr('dy', '-.33em')
      .attr('x', 80)
      .attr('y', (d, i) => @yGLegend(i))
      .text((m) => @datumToString(m.get('d')))
      .call @wrap, Visio.Constants.EXPORT_LEGEND_WIDTH - 80

    gLegends.exit().remove()

    gLegendLabels = @gLegend.selectAll('.g-legend-label').data @gLegendData.models
    gLegendLabels.enter().append('text')
    gLegendLabels
      .attr('class', (d) => ['g-legend-label', @datumClass(d)].join(' '))
      .attr('text-anchor', 'start')
      .attr('dy', '-.33em')
      .attr('x', 40)
      .attr('y', (d, i) => @yGLegend(i))
      .text((m) => m.get('label'))

    gLegendLabels.exit().remove()

  datumClass: ->

  datumId: (d) =>
    d.id

  datumToString: (d) =>
    d.toString()

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

  close: ->
    @selectedDatum.off()

    # remove any tipsy elements
    $('.tipsy').remove()
    @unbind()
    @remove()
