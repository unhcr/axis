module 'ABSY Figure',
  setup: ->
    @el = $('<div></div>')[0]
    @figure = Visio.Figures.absy(
      margin:
        left: 0
        right: 0
        top: 0
        bottom: 0
      width: 100
      height: 100
      selection: d3.select(@el))
    @d = new Visio.Models.Output({ id: 1 })
    sinon.stub @d, 'selectedAmount', -> 10
    sinon.stub @d, 'selectedAchievement', -> { result: 10 }

  teardown: ->
    $.unsubscribe('select.absy')
    @d.selectedAmount.restore()
    @d.selectedAchievement.restore()

test 'render', ->
  @figure.data [@d]
  @figure()

  ok d3.selectAll('.bubble').length, 1

  @d.selectedAmount.restore()
  sinon.stub @d, 'selectedAmount', -> 0

  @figure()
  ok d3.selectAll('.bubble').length, 0

test 'filterFn', ->
  ok Visio.Figures.absy.filterFn
  ok Visio.Figures.absy.filterFn instanceof Function

  ok Visio.Figures.absy.filterFn(@d), 'Should not be filtered'

  @d.selectedAmount.restore()
  sinon.stub @d, 'selectedAmount', -> 0
  ok not Visio.Figures.absy.filterFn(@d), 'Should be filtered'

  @d.selectedAmount.restore()
  @d.selectedAchievement.restore()
  sinon.stub @d, 'selectedAmount', -> 10
  sinon.stub @d, 'selectedAchievement', -> { result: undefined }
  ok not Visio.Figures.absy.filterFn(@d), 'Should be filtered'


test 'select', ->
  @figure.data [@d]
  @figure()

  ok d3.select(@el).selectAll('.active').length, 0, 'Should have no active bubbles'

  $.publish('select.absy', [@d])
  ok d3.select(@el).selectAll('.active').length, 1, 'Should have one active bubble'
