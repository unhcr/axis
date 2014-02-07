class Visio.Collections.Parameter extends Visio.Collections.Syncable

  model: Visio.Models.Parameter

  comparator: (a, b) ->
    aName = a.toString()
    bName = b.toString()
    return -1 if aName < bName
    return 1 if aName > bName
    return 0 if aName == bName

  search: (query) ->
    $.get("#{@url}/search", { query: query })

