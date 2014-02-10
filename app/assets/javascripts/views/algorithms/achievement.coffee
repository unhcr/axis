class Visio.Views.AchievementView extends Backbone.View

  template: HAML['algorithms/achievement']

  initialize: ->
    @render()

  render: ->
    @$el.html @template()


