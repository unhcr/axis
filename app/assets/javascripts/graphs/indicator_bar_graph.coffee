Visio.Graphs.indicatorBarGraph = (config) ->
  margin = config.margin

  width = config.width - margin.left - margin.right
  height = config.height - margin.top - margin.bottom

  selection = config.selection

  duration = 500

  isPerformance = false

  svg = selection.append('svg')
    .attr('width', config.width)
    .attr('height', config.height)

  g = svg.append('g')
    .attr('transform', "translate(#{margin.left}, #{margin.top})")

  barWidth = 10

  x = d3.scale.linear()
    .domain([0, 30])
    .range([0, width])

  y = d3.scale.linear()
    .domain([0, 100])
    .range([height, 0])

  data = []


  render = () ->

    boxes = g.selectAll('g.box').data(data)
    boxes.enter().append('g')
    boxes.attr('class', 'box')
      .attr('transform', (d, i) ->
        'translate(' + x(i) + ', 0)'
      )
      .each((d, i) ->
        bar = d3.select @

        reversed = d.get('baseline') > d.get('myr')
        barHeight = Math.abs(d.get('baseline') - d.get('myr'))
        console.log barHeight
        console.log '---'
        console.log d.get('baseline')
        console.log d.get('myr')
        console.log d.get('yer')
        myrBox = bar.selectAll('.myrBox').data([d])
        myrBox.enter().append('rect')
        myrBox.attr('class', (d) ->
          classes = ['myrBox']
          classes.push 'reversed' if reversed
          classes.join ' '
        ).attr('x', 0)
          .attr('y', (d) ->
            if reversed
              return y(d.get('myr') + barHeight)
            else
              return y(d.get('baseline') + barHeight)
          ).attr('width', barWidth)
          .attr('height', (d) ->
            return y(0) - y(barHeight))


        reversed = d.get('myr') > d.get('yer')
        barHeight = Math.abs(d.get('myr') - d.get('yer'))
        yerBox = bar.selectAll('.yerBox').data([d])
        yerBox.enter().append('rect')
        yerBox.attr('class', (d) ->
          classes = ['yerBox']
          classes.push 'reversed' if reversed
          classes.join ' '
        ).attr('x', 0)
          .attr('y', (d) ->
            if reversed
              return y(d.get('yer') + barHeight)
            else
              return y(d.get('myr') + barHeight)
          ).attr('width', barWidth)
          .attr('height', (d) ->
            return y(0) - y(barHeight))

        center = bar.selectAll('.center').data([d])
        center.enter().append('line')
        center.attr('class', 'center')
          .attr('x1', barWidth / 2)
          .attr('y1', (d) -> y(d.get('yer')))
          .attr('x2', barWidth / 2)
          .attr('y2', (d) -> y(d.get('comp_target')))

      )

  render.data = (_data) ->
    return data unless arguments.length
    data = _data.where { is_performance: isPerformance }
    render

  render.isPerformance = (_isPerformance) ->
    return _isPerformance unless arguments.length
    isPerformance = _isPerformance
    render



  render

