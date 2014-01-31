@Fixtures = {}
@Fixtures.budgets = new Visio.Collections.Budget([
    {
      id: 'r'
      amount: 10
      scenario: Visio.Scenarios.AOL
      budget_type: Visio.Budgets.ADMIN
      year: 2012
    },
    {
      id: 'g'
      amount: 20
      scenario: Visio.Scenarios.OL
      budget_type: Visio.Budgets.ADMIN
      year: 2013
    },
    {
      id: 'y'
      amount: 40
      scenario: Visio.Scenarios.OL
      budget_type: Visio.Budgets.ADMIN
      year: 2013
    },
    {
      id: 'b'
      amount: 30
      scenario: Visio.Scenarios.AOL
      budget_type: Visio.Budgets.PROJECT
      year: 2013
    },

])
