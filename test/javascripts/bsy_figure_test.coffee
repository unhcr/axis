module 'BSY Figure',
  setup: ->
    Visio.manager = new Visio.Models.Manager()
    @figure = new Visio.Figures.Bsy
      margin:
        left: 0
        right: 0
        top: 0
        bottom: 0
      width: 100
      height: 100

    @data = new Visio.Collections.Operation [
      {
        id: 'wilson'
        name: 'willy'
      },
      {
        id: 'george'
        name: 'bigG'
      }
    ]

test 'filtered', ->
  filtered = @figure.filtered @data
  strictEqual filtered.length, 2

test 'render', ->

  @figure.collectionFn @data
  @figure.render()

  strictEqual @figure.$el.find('.box').length, 2


test 'hover - datum', ->
  @figure.collectionFn @data
  @figure.render()


  datum = @data.get 'wilson'
  $.publish "hover.#{@figure.cid}.figure", datum

  strictEqual @figure.hoverDatum.id, datum.id
  ok @figure.$el.find(".box-#{datum.id} .hover").length, 'Should have hover element'

test 'hover - idx', ->
  @figure.collectionFn @data
  @figure.render()


  datum = @data.get 'wilson'
  $.publish "hover.#{@figure.cid}.figure", 1

  strictEqual @figure.hoverDatum.id, datum.id
  ok @figure.$el.find(".box-#{datum.id} .hover").length, 'Should have hover element'

test 'query', ->
  @figure.query = 'willy'
  strictEqual @figure.filtered(@data).length, 1, 'Should not be filtered'

  @figure.query = ''
  strictEqual @figure.filtered(@data).length, 2, 'Should not be filtered'

  @figure.query = 'g'
  strictEqual @figure.filtered(@data).length, 1, 'Should not be filtered'

