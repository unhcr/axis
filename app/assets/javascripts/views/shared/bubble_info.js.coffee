class Visio.Views.BubbleInfoView extends Backbone.View

  template: JST['shared/bubble_info']

  initialize: (options) ->

  render: (datum) ->
    @$el.html @template(datum)

  show: () ->
    @$el.removeClass('gone')
    @$el.siblings().addClass('gone')

  hide: () ->
    @$el.addClass('gone')
    @$el.siblings().removeClass('gone')

