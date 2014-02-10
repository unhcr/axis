module 'Expenditure',
  setup: () ->
    Visio.user = new Visio.Models.User()
    Visio.manager = new Visio.Models.Manager()

  teardown: ->
    Visio.manager.get('db').clear()


test 'amount', () ->

  expenditures = new Visio.Collections.Expenditure([
    {
      id: 'r'
      amount: 10
      scenario: Visio.Scenarios.AOL
      budget_type: Visio.Budgets.ADMIN
    },
    {
      id: 'g'
      amount: 20
      scenario: Visio.Scenarios.OL
      budget_type: Visio.Budgets.ADMIN
    },
    {
      id: 'b'
      amount: 30
      scenario: Visio.Scenarios.AOL
      budget_type: Visio.Budgets.PROJECT
    },

  ])

  total = expenditures.amount()
  strictEqual(total, 60)

  Visio.manager.get('scenario_type')[Visio.Scenarios.OL] = false
  total = expenditures.amount()
  strictEqual(total, 60)

  Visio.manager.get('budget_type')[Visio.Budgets.PROJECT] = false
  total = expenditures.amount()
  strictEqual(total, 60)

