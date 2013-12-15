module 'Budget',
  setup: () ->
    Visio.user = new Visio.Models.User()
    Visio.manager = new Visio.Models.Manager()

test 'budget', () ->

  budgets = new Visio.Collections.Budget([
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

  total = budgets.budget()
  strictEqual(total, 60)

  Visio.manager.get('scenario_type')[Visio.Scenarios.OL] = false
  total = budgets.budget()
  strictEqual(total, 40)

  Visio.manager.get('budget_type')[Visio.Budgets.PROJECT] = false
  total = budgets.budget()
  strictEqual(total, 10)
