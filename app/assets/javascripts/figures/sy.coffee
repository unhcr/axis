# Single year figure abstract class
class Visio.Figures.Sy extends Visio.Figures.Base

  @include Visio.Mixins.Exportable

  findBoxByIndex: (idx) =>
    boxes = @g.selectAll('.box')
    result = { box: null, idx: idx, datum: null }
    boxes.sort(@transformSortFn).each (d, i) ->
      if idx == i
        result.box = d3.select(@)
        result.datum = d

    result


  findBoxByDatum: (datum) =>
    boxes = @g.selectAll('.box')
    result = { box: null, idx: null, datum: datum }
    boxes.sort(@transformSortFn).each (d, i) ->
      if d.id == datum.id
        result.box = d3.select(@)
        result.idx = i

    result

  select: (e, d, i) =>
    super d, i

    box = @g.select(".box-#{d.id}")
    isActive = box.classed 'active'
    box.classed 'active', not isActive

    @renderSvgLegend d, i

  boxClasslist: (d, i) =>
    classList = ['box', "box-#{d.id}"]
    classList.push 'selected' if d.id == @selectedDatum.get('d')?.id
    classList.push 'active' if @activeData?.get(d.id)?
    classList.push 'box-invisible'  if @x(i) < @x.range()[0] or @x(i) + 3 * @barWidth  > @x.range()[1]
    classList.push 'gone'  if @x(i) < @x.range()[0] or @x(i) + 3 * @barWidth  > @x.range()[1]
    classList.join ' '

  close: ->
    super
    $.unsubscribe "hover.#{@cid}.figure"
    $.unsubscribe "mouseout.#{@cid}.figure"

