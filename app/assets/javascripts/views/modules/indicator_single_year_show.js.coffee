class Visio.Views.IndicatorSingleYearShowView extends Backbone.View

  template: JST['modules/indicator_single_year_show']

  initialize: (options) ->

  render: () ->
    @$el.html @template({ parameter: @model })
    @

  events:
    'click .js-parameter': 'onClickParameter'

  onClickParameter: (e) ->
    @$el.find('.js-data').toggleClass 'gone'
