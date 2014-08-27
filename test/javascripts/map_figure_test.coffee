module 'Map Figure',
  setup: ->
    Visio.user = new Visio.Models.User()
    Visio.manager = new Visio.Models.Manager()
    Visio.manager.set 'reported_type', Visio.Algorithms.REPORTED_VALUES.myr

    country =
      latlng: [33, 65]
      iso3: 'AFG'
      name: 'Afghanistan'

    country2 =
      latlng: [-20, 30]
      iso3: 'ZWE'
      name: 'Zimbabwe'

    @operations = new Visio.Collections.Operation [
      { id: 1, year: 2012, country: country, strategy_ids: [1, 2] },
      { id: 2, year: 2013, country: country, strategy_ids: [1] },
      { id: 4, year: 2012, country: country2, strategy_ids: [2] },
      { id: 5, year: 2013, country: country2, strategy_ids: [1] },
      { id: 3, year: 2012, strategy_ids: [] }]

    @operations.each (p) ->
      sinon.stub p, 'strategySituationAnalysis', ->
        { category: 'success' }

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

  teardown: ->
    @operations.each (p) ->
      p.strategySituationAnalysis.restore()


test 'render', ->
  Visio.manager.year 2012

  @map.render()

  strictEqual @map.$el.find('.country').length, 3, 'Should have 3 countries'
  strictEqual @map.$el.find('.country.BEN').length, 1, 'Should have ISO in class'

  @map.collectionFn @operations
  @map.render()

test 'pan', ->

  @map.render()

  extent = @map.translateExtent

  dx = extent.right - @map.zoom.translate()[0]

  @map.pan(dx, 0)
  strictEqual @map.zoom.translate()[0], extent.right, 'Should move to the right most extent'

  @map.pan(-20, 0)
  strictEqual @map.zoom.translate()[0], extent.right, 'Should not move past extent'

test 'zoom', ->
  @map.render()

  scale = @map.zoom.scale()
  strictEqual scale, 1

  @map.zoomIn()
  scale = @map.zoom.scale()
  strictEqual scale, 1 + @map.zoomStep

  @map.zoomOut()
  scale = @map.zoom.scale()
  ok .99 < scale < 1.01

test 'filtered', ->
  Visio.manager.year 2012

  filtered = @map.filtered @operations
  strictEqual filtered.length, @operations.length - 1

  @operations.at(0).set 'country', null

  filtered = @map.filtered @operations
  strictEqual filtered.length, @operations.length - 2, 'Should filter operations without a country'
