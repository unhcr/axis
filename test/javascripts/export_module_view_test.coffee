module 'Export Module View',
  setup: ->
    Visio.user = new Visio.Models.User()
    Visio.manager = new Visio.Models.Manager()
    figureType = 'isy'
    @figureId = 'myid-export'
    @el = $('<div></div>')[0]
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
    config =
      margin:
        left: 0
        right: 0
        top: 0
        bottom: 0
      width: 100
      height: 100
      selection: d3.select(@el)
      data: @data.models
      figureId: @figureId

    Visio.FigureInstances[@figureId] = Visio.Figures[figureType](config)

    @model = new Visio.Models.ExportModule
      figure_type: figureType
      figure_id: @figureId + '-export'
      state: Visio.manager.state()
      data: Visio.FigureInstances[@figureId].data().filter(
        Visio.Figures[figureType].filterFn.bind(Visio.FigureInstances[@figureId]))
    @exportView = new Visio.Views.ExportModule( model: @model)

  teardown: ->
    Visio.FigureInstances[@figureId].unsubscribe()
    @exportView.close()


test 'render', ->
  @exportView.render()

  strictEqual $(@exportView.el).find('figcaption input').length,
    @data.where( is_performance: @exportView.figure.isPerformance()).length

test 'select', ->
  @exportView.render()
  d = _.find @model.get('data'), (d) -> d.index == 0

  $.publish "select.#{@model.get('figure_id')}", [d]
  strictEqual @exportView.$el.find(':checked').length, 1, 'Should make one active'
  strictEqual @exportView.$el.find('figure .active').length, 1, 'Should make one active in isy figure'

  $.publish "select.#{@model.get('figure_id')}", [d]
  strictEqual @exportView.$el.find(':checked').length, 0, 'Should toggle it off'
  strictEqual @exportView.$el.find('figure .active').length, 0, 'Should toggle off active in isy figure'

  $.publish "select.#{@model.get('figure_id')}.figure", [d]
  strictEqual @exportView.$el.find(':checked').length, 0, 'Should not affect view'
  strictEqual @exportView.$el.find('figure .active').length, 1, 'Should toggle on active in isy figure'




