# Single year figure abstract class
class Visio.Figures.Sy extends Visio.Figures.Base

  @include Visio.Mixins.Exportable

  findBoxByIndex: (idx) =>
    datum = @_filtered[idx]
    box = @g.select(".box-#{datum.id}")
    result = { box: box, idx: idx, datum: datum }

    result


  findBoxByDatum: (datum) =>
    idx = _.indexOf @_filtered, datum
    box = @g.select(".box-#{datum.id}")
    result = { box: box, idx: idx, datum: datum }

    result

  select: (e, d, i) =>
    super d, i

    box = @g.select(".box-#{d.id}")
    isActive = box.classed 'active'
    box.classed 'active', not isActive

    @renderSvgLabels()

  activeFn: (d) =>
    @activeData?.get(d.id)?

  boxClasslist: (d, i) =>
    classList = ['box', "box-#{d.id}"]
    classList.push 'selected' if d.id == @selectedDatum.get('d')?.id
    classList.push 'active' if @activeData?.get(d.id)?
    classList.push 'box-invisible'  if @x(i) < @x.range()[0] or @x(i) + 3 * @barWidth  > @x.range()[1]
    classList.push 'gone'  if @x(i) < @x.range()[0] or @x(i) + 3 * @barWidth  > @x.range()[1]
    classList.join ' '

  getPNGSvg: =>
    @render { isPng: true }
    @renderSvgLabels()
    $(@$el.find('svg')[0])

  getMax: => 0

  close: ->
    super
    $.unsubscribe "hover.#{@cid}.figure"
    $.unsubscribe "mouseout.#{@cid}.figure"

