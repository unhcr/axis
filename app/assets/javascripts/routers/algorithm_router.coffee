class Visio.Routers.AlgorithmsRouter extends Backbone.Router

  initialize: ->

  routes:
    'achievement': 'achievement'
    'situation_analysis': 'situationAnalysis'
    '*default': 'achievement'

  achievement: ->
    @view = new Visio.Views.AchievementView({ el: $('#algorithm') })

  situationAnalysis: ->
    @view = new Visio.Views.SituationAnalysisView({ el: $('#algorithm') })
