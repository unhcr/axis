module 'Operation',

  setup: () ->
    Visio.user = new Visio.Models.User()
    Visio.manager = new Visio.Models.Manager()
    Visio.manager.set 'selected', { ppgs: { 'A': true, 'B': true, 'C': true } }

    @operation = new Visio.Models.Operation
      populations: [
        {
          ppg_id: 'A'
          value: 5
        },
        {
          ppg_id: 'B'
          value: 5
        },
        {
          ppg_id: 'C'
          value: 5
        }
      ]

test 'selectedPopulation', ->

  value = @operation.selectedPopulation()

  strictEqual value, 15, 'All selected'

  Visio.manager.set 'selected', { ppgs: { 'A': true } }
  value = @operation.selectedPopulation()
  strictEqual value, 5, 'One selected'

  Visio.manager.set 'selected', { ppgs: {} }
  value = @operation.selectedPopulation()
  strictEqual value, 0, 'None selected'
