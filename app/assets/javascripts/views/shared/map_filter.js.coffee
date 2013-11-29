class Visio.Views.MapFilterView extends Backbone.View

  className: 'map-filters'

  filters: ['Year']

  initialize: (options) ->

    @render()

  render: () ->
    @filters.each (filter) =>
      @filterViews = Visio.Views["#{filter}FilterView"]

      @$el.append @filterViews.el

    $('body').append @el
    @
