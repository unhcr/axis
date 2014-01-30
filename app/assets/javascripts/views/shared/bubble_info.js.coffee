class Visio.Views.BubbleInfoView extends Backbone.View

  template: HAML['shared/bubble_info']

  initialize: (options) ->

  render: (datum) ->
    @$el.html @template({ datum: datum })

  show: () ->
    @$el.removeClass('gone')
    @$el.siblings().addClass('gone')

  hide: () ->
    @$el.addClass('gone')
    @$el.siblings().removeClass('gone')

