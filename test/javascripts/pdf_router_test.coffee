module 'PDF Router',
  setup: ->
    stop()
    Visio.user = new Visio.Models.User()
    Visio.manager = new Visio.Models.Manager({
      strategy_id: 1
      strategies: new Visio.Collections.Strategy([{ id: 1, operation_ids: {20:true} }, { id: 2 }]),
      ready: ->
        start()
    })
    @o = Fixtures.outputs
    @sos = Fixtures.strategyObjectives

    sinon.stub Visio.Models.Output.prototype, 'selectedBudget', -> 10
    sinon.stub Visio.Models.Output.prototype, 'selectedAchievement', -> { result: 10 }

    sinon.stub Visio.Models.StrategyObjective.prototype, 'selectedBudget', -> 10
    sinon.stub Visio.Models.StrategyObjective.prototype, 'selectedAchievement', -> { result: 10 }
  teardown: ->
    Visio.manager.get('db').clear()
    Visio.Models.Output.prototype.selectedBudget.restore()
    Visio.Models.Output.prototype.selectedAchievement.restore()
    Visio.Models.StrategyObjective.prototype.selectedBudget.restore()
    Visio.Models.StrategyObjective.prototype.selectedAchievement.restore()

test 'index - absy aggregated by SO', ->
  Backbone.history.start({ silent: true}) unless Backbone.History.started
  Visio.manager.set 'aggregation_type', Visio.Parameters.STRATEGY_OBJECTIVES.plural
  @absy = new Visio.Figures.Absy
    margin:
      left: 0
      right: 0
      top: 0
      bottom: 0
    width: 100
    height: 100
    collection: @sos

  config = @absy.config()
  config.selected = ["#{@sos.at(0).id}"]

  Visio.router = new Visio.Routers.PdfRouter
    selector: $('<div></div>')
    config:
      figure_config: config

  sinon.stub Visio.router, 'setup', ->
    Visio.router.absy()
    return $.Deferred().resolve().promise()
  Visio.router.index()

  ok Visio.router.view?
  ok Visio.router.view.isPdf
  strictEqual Visio.router.view.$el.find('.svg-absy-figure').length, 1
  strictEqual Visio.router.view.$el.find('.svg-absy-figure .active').length, 1
  strictEqual Visio.router.view.$el.find('.svg-absy-figure .label').length, 1
  strictEqual Visio.router.view.$el.find('.parameter-show').length, 1

  Visio.router.setup.restore()

test 'index - absy', ->
  Backbone.history.start({ silent: true}) unless Backbone.History.started
  @absy = new Visio.Figures.Absy
    margin:
      left: 0
      right: 0
      top: 0
      bottom: 0
    width: 100
    height: 100
    collection: @o

  config = @absy.config()
  config.selected = [@o.at(0).id]

  Visio.router = new Visio.Routers.PdfRouter
    selector: $('<div></div>')
    config:
      figure_config: config

  sinon.stub Visio.router, 'setup', ->
    Visio.router.absy()
    return $.Deferred().resolve().promise()
  Visio.router.index()

  ok Visio.router.view?
  ok Visio.router.view.isPdf
  strictEqual Visio.router.view.$el.find('.svg-absy-figure').length, 1
  strictEqual Visio.router.view.$el.find('.parameter-show').length, 1

  Visio.router.setup.restore()

test 'index - icmy', ->
  Backbone.history.start({ silent: true}) unless Backbone.History.started
  @icmy = new Visio.Figures.Icmy
    margin:
      left: 0
      right: 0
      top: 0
      bottom: 0
    width: 100
    height: 100
    collection: @o

  config = @icmy.config()

  Visio.router = new Visio.Routers.PdfRouter
    selector: $('<div></div>')
    config:
      figure_config: config

  sinon.stub Visio.router, 'setup', ->
    return $.Deferred().resolve().promise()

  Visio.router.index()

  ok Visio.router.view?
  ok Visio.router.view.isPdf
  strictEqual Visio.router.view.$el.find('.svg-icmy-figure').length, 1

  Visio.router.setup.restore()


