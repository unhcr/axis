module 'Map Figure',
  setup: ->
    Visio.user = new Visio.Models.User()
    Visio.manager = new Visio.Models.Manager()

    model = new Visio.Models.Map({ map: Fixtures.topo })
    @map = new Visio.Figures.Map
      model: model
      margin:
        top: 0
        left: 0
        right: 0
        bottom: 0
      width: 100
      height: 100

test 'render', ->

  @map.render()

  strictEqual @map.$el.find('.country').length, 3, 'Should have 3 countries'
  strictEqual @map.$el.find('.country.BEN').length, 1, 'Should have ISO in class'

test 'pan', ->

  @map.render()

  extent = @map.translateExtent

  dx = extent.right - @map.zoom.translate()[0]

  console.log @map.zoom.translate()
  @map.pan(dx, 0)
  strictEqual @map.zoom.translate()[0], extent.right, 'Should move to the right most extent'

  @map.pan(-20, 0)
  strictEqual @map.zoom.translate()[0], extent.right, 'Should not move past extent'
