class Visio.Views.IndicatorDatumShowView extends Backbone.View

  className: 'indicator-datum col-md-3'

  template: HAML['shared/indicator_datum_show']

  events:
    'click .name': 'onNameClick'

  render: ->
    @$el.html @template({ model: @model })
    @

  onNameClick: ->
    @$el.find('.info').toggleClass 'gone'

