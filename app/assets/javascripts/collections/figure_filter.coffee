# The FigureFilter is a collection of filters used on figures
# This is the collection behind the FilterBy dropdown view
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

