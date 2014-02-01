class Visio.Collections.Operation extends Visio.Collections.Parameter

  model: Visio.Models.Operation

  url: '/operations'

  name: Visio.Parameters.OPERATIONS

  comparator: (a, b) ->
    aName = a.toString()
    bName = b.toString()
    return -1 if aName < bName
    return 1 if aName > bName
    return 0 if aName == bName


