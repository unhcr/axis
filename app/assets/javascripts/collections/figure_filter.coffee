class Visio.Collections.FigureFilter extends Backbone.Collection

  model: Visio.Models.FigureFilter

  isFiltered: (datum) ->
    not @every (filter) ->
      not filter.isFiltered(datum)

  filter: (filterType, filterValue) ->
    filter = @get filterType
    filter.get('values')[filterValue]

  resetFilters: ->
    @each (filter) ->
      filter.resetFilter() unless filter.get('hidden')

