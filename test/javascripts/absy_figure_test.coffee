module 'ABSY Figure',
  setup: ->
    Visio.manager = new Visio.Models.Manager()
    @figure = new Visio.Figures.Absy(
      margin:
        left: 0
        right: 0
        top: 0
        bottom: 0
      width: 100
      height: 100
      )
    @d = new Visio.Models.Output({ id: 1 })
    sinon.stub @d, 'selectedAmount', -> 10
    sinon.stub @d, 'selectedAchievement', -> { result: 10 }

  teardown: ->
    @figure.unsubscribe()
    @d.selectedAmount.restore()
    @d.selectedAchievement.restore()

test 'render', ->
  @figure.collectionFn new Visio.Collections.Output([@d])
  @figure.render()

  ok d3.select(@figure.el).selectAll('.bubble').size(), 1
  strictEqual @figure.x.domain()[0], 0
  strictEqual @figure.x.domain()[1], 10

  @d.selectedAmount.restore()
  sinon.stub @d, 'selectedAmount', -> 0

  @figure.render()
  ok d3.select(@figure.el).selectAll('.bubble').size(), 0

test 'filtered', ->

  collection = new Visio.Collections.Output([@d])

  strictEqual @figure.filtered(collection).length, 1, 'Should not be filtered'

  @d.selectedAmount.restore()
  sinon.stub @d, 'selectedAmount', -> 0
  ok not @figure.filtered(collection).length, 'Should be filtered'

  @d.selectedAmount.restore()
  @d.selectedAchievement.restore()
  sinon.stub @d, 'selectedAmount', -> 10
  sinon.stub @d, 'selectedAchievement', -> { result: undefined }
  ok not @figure.filtered(collection).length, 'Should be filtered'


test 'select', ->
  @figure.collectionFn new Visio.Collections.Output([@d])
  @figure.render()

  ok d3.select(@figure.el).selectAll('.active').empty(), 'Should have no active bubbles'

  $.publish("select.#{@figure.figureId()}.figure", [@d, 0])

  ok not @figure.isExport, 'Should not be export'
  ok d3.select(@figure.el).selectAll('.active').empty(), 'Should not have active bubbles since it is not export'

  @figure.subscribe()
  $.publish("select.#{@figure.figureId()}.figure", [@d, 0])
  strictEqual d3.select(@figure.el).selectAll('.active').size(), 1, 'Should have one active bubble'

test 'el', ->
  @figure.collectionFn new Visio.Collections.Output([@d])
  @figure.render()

  ok @figure.el.innerHTML != '', 'Figure should have something in it'

  $(@figure.el).html ''

  strictEqual @figure.el.innerHTML, '', 'Figure should be empty'
