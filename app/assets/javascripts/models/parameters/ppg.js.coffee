class Visio.Models.Ppg extends Visio.Models.Parameter

  urlRoot: '/ppgs'

  paramRoot: 'ppg'

  toString: () ->
    return "[#{@get('operation_name')}] #{@get('name')}"

  name: Visio.Parameters.PPGS

  highlight: ->
    return "[#{@get('operation_name')}] #{@get('highlight').name[0]}" if @get('highlight')
