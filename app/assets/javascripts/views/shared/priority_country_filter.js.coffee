class Visio.Views.PriorityCountryFilterView extends Backbone.View

  className: 'priority-country-filter map-filter'

  template: JST['shared/priority_country_filter']

  initialize: (options) ->

    @render()

  render: () ->
    @$el.html @template()
    @
