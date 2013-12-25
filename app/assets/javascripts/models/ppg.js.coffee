class Visio.Models.Ppg extends Visio.Models.Parameter

  urlRoot: '/ppgs'

  paramRoot: 'ppg'

  toString: () ->
    return "[#{@get('operation_name')}] #{@get('name')}"

  name: Visio.Parameters.PPGS.plural
