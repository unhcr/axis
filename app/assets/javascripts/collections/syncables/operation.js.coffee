class Visio.Collections.Operation extends Visio.Collections.Syncable

  model: Visio.Models.Operation

  url: '/operations'

  name: Visio.Syncables.OPERATIONS.plural

  comparator: (a, b) ->
    aName = a.toString()
    bName = b.toString()
    return -1 if aName < bName
    return 1 if aName > bName
    return 0 if aName == bName


