class Visio.Collections.FigureFilter extends Backbone.Collection

  model: Visio.Models.FigureFilter

  isFiltered: (datum) ->
    not @every (filter) ->
      not filter.isFiltered(datum)

  resetFilters: ->
    @each (filter) -> filter.resetFilter()

