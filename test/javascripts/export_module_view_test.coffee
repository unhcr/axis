module 'Export Module View',
  setup: ->
    Visio.user = new Visio.Models.User()
    Visio.manager = new Visio.Models.Manager()
    figureType = 'isy'
    @figureId = 'myid-export'
    @data = new Visio.Collections.IndicatorDatum([
        {
          id: 'ben'
          is_performance: false
          baseline: 0
          myr: 10
          yer: 20
          comp_target: 50
          standard: 50
        },
        {
          id: 'jeff'
          is_performance: true
          baseline: 0
          myr: 10
          yer: 20
          comp_target: 50
        },
        {
          id: 'lisa'
          is_performance: true
          baseline: 0
          myr: 10
          yer: 20
          comp_target: 50
        }
      ])
    @config =
      margin:
        left: 0
        right: 0
        top: 0
        bottom: 0
      width: 100
      height: 100
      data: @data.models
      isExport: true
      isPerformance: true

    Visio.FigureInstances[@figureId] = Visio.Figures[figureType](@config)
    @config.figureId = Visio.FigureInstances[@figureId].exportId()

    @model = new Visio.Models.ExportModule
      figure_type: figureType
      state: Visio.manager.state()
      figure_config: @config

    @exportView = new Visio.Views.ExportModule( model: @model)

  teardown: ->
    for key, val of Visio.FigureInstances
      Visio.FigureInstances[key].unsubscribe()
    @exportView.close()


test 'render', ->
  @exportView.render()

  strictEqual $(@exportView.el).find('figcaption input').length, 2
  strictEqual $(@exportView.el).find('figure .box').length, 2

test 'select', ->
  @exportView.render()
  i = 0
  d = @exportView.filtered[i]
  strictEqual $(@exportView.el).find('figcaption input').length, 2
  strictEqual $(@exportView.el).find('figure .box').length, 2

  $.publish "select.#{@model.get('figure_config').figureId}", [d, i]
  strictEqual @exportView.$el.find(':checked').length, 1, 'Should make one active'
  strictEqual @exportView.$el.find('figure .active').length, 1, 'Should make one active in isy figure'

  $.publish "select.#{@model.get('figure_config').figureId}", [d, i]
  strictEqual @exportView.$el.find(':checked').length, 0, 'Should toggle it off'
  strictEqual @exportView.$el.find('figure .active').length, 0, 'Should toggle off active in isy figure'

  $.publish "select.#{@model.get('figure_config').figureId}.figure", [d, i]
  strictEqual @exportView.$el.find(':checked').length, 0, 'Should not affect view'
  strictEqual @exportView.$el.find('figure .active').length, 1, 'Should toggle on active in isy figure'

test 'Required functions', ->
  figures = ['absy', 'isy', 'bmy']
  requiredFns = ['filtered', 'exportId', 'config', 'el', 'unsubscribe', 'figureId']

  _.each figures, (figure) =>
    f = Visio.Figures[figure](@config)

    _.each requiredFns, (fn) ->
      ok f[fn] instanceof Function, "Must have filtered function for #{figure}"

