class Visio.Views.BubbleInfoView extends Backbone.View

  template: HAML['shared/bubble_info']

  initialize: (options) ->
    @filters = options.filters

  render: (datum, algorithm) ->
    achievement = datum.selectedAchievement Visio.manager.year(), @filters
    value = datum[algorithm] Visio.manager.year(), @filters
    @$el.html @template
      title: datum.toString()
      achievement: achievement
      value: value
      algorithm: algorithm

  show: () ->
    @$el.removeClass('gone')
    @$el.siblings().addClass('gone')

  hide: () ->
    @$el.addClass('gone')
    @$el.siblings().removeClass('gone')

