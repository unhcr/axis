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

    @plans = new Visio.Collections.Plan [
      { id: 1, year: 2012, country: country, strategy_ids: [1, 2] },
      { id: 2, year: 2013, country: country, strategy_ids: [1] },
      { id: 4, year: 2012, country: country2, strategy_ids: [2] },
      { id: 5, year: 2013, country: country2, strategy_ids: [1] },
      { id: 3, year: 2012, strategy_ids: [] }]

    @plans.each (p) ->
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
    @plans.each (p) ->
      p.strategySituationAnalysis.restore()


test 'render', ->
  Visio.manager.year 2012

  @map.render()

  strictEqual @map.$el.find('.country').length, 3, 'Should have 3 countries'
  strictEqual @map.$el.find('.country.BEN').length, 1, 'Should have ISO in class'

  @map.collectionFn @plans
  @map.render()

  strictEqual _.chain(@map.views).values().filter((v) -> !v.$el.hasClass('gone')).value().length, 2,
    'Should have 2 pin views'
  _.each @map.views, (view) ->
    ok view.isShrunk()
    ok !view.isExpanded()

    view.expand()
    ok view.isExpanded()

    view.shrink()
    ok view.isShrunk()

  selectedStrategies = { 1: true }
  Visio.manager.set 'selected_strategies', selectedStrategies

  @map.render()
  strictEqual _.chain(@map.views).values().filter((v) -> !v.$el.hasClass('gone')).value().length, 1,
    'Should have 1 pin view'

  Visio.manager.year 2013
  # Need to clear tooltips after year change
  @map.clearTooltips()

  @map.render()
  strictEqual _.chain(@map.views).values().filter((v) -> !v.$el.hasClass('gone')).value().length, 2,
    'Should have 2 pin views showing'


test 'pan', ->

  @map.render()

  extent = @map.translateExtent

  dx = extent.right - @map.zoom.translate()[0]

  console.log @map.zoom.translate()
  @map.pan(dx, 0)
  strictEqual @map.zoom.translate()[0], extent.right, 'Should move to the right most extent'

  @map.pan(-20, 0)
  strictEqual @map.zoom.translate()[0], extent.right, 'Should not move past extent'

test 'filtered', ->
  Visio.manager.year(2012)

  filtered = @map.filtered @plans

  strictEqual filtered.length, 2
  ok _.findWhere(filtered, { id: 1 })
  ok _.findWhere(filtered, { id: 4 })

  Visio.manager.get('strategies').reset [{ id: 1 }, { id: 2 }]
  Visio.manager.set 'selected_strategies', {}

  filtered = @map.filtered @plans
  strictEqual filtered.length, 2
  ok _.findWhere(filtered, { id: 1 })
  ok _.findWhere(filtered, { id: 4 })

  selectedStrategies = { 1: true }
  Visio.manager.set 'selected_strategies', selectedStrategies

  filtered = @map.filtered @plans
  strictEqual filtered.length, 1
  ok _.findWhere(filtered, { id: 1 })
