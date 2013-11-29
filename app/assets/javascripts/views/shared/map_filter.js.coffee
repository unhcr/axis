class Visio.Views.MapFilterView extends Backbone.View

  className: 'map-filters'

  filters: ['Year']

  initialize: (options) ->

    @render()

  render: () ->
    _.each @filters, (filter) =>
      @filterViews = new Visio.Views["#{filter}FilterView"]

      @$el.append @filterViews.el

    $('header').after @el
    @
