class Visio.Routers.AlgorithmsRouter extends Backbone.Router

  initialize: ->

  routes:
    'achievement': 'achievement'
    'situation_analysis': 'situationAnalysis'
    '*default': 'achievement'

  achievement: ->
    @view = new Visio.Views.AlgorithmView
      el: $('#algorithm'),
      collection: new Visio.Collections.IndicatorDatum()
      algorithm: 'achievement'

  situationAnalysis: ->
    @view = new Visio.Views.AlgorithmView
      el: $('#algorithm'),
      collection: new Visio.Collections.IndicatorDatum()
      algorithm: 'situationAnalysis'
