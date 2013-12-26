module 'MapFilters',
  setup: ->
    Visio.manager = new Visio.Models.Manager()

test 'render', ->
  view = new Visio.Views.MapFilterView()

  ok view.el
  strictEqual view.$el.find('.map-filter').length, view.filters.length

