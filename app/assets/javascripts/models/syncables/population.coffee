class Visio.Models.Population extends Visio.Models.AmountType

  urlRoot: '/populations'

  paramRoot: 'population'

  name: Visio.Syncables.POPULATIONS

  amount: ->
    @get 'value'

