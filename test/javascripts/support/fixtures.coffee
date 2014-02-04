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
@Fixtures.data = new Visio.Collections.IndicatorDatum([
    {
      id: 'ben'
      is_performance: false
      baseline: 0
      myr: 10
      yer: 20
      comp_target: 50
      standard: 50
    },
    {
      id: 'jeff'
      is_performance: true
      baseline: 0
      myr: 10
      yer: 20
      comp_target: 50
    },
    {
      id: 'lisa'
      is_performance: true
      baseline: 0
      myr: 10
      yer: 20
      comp_target: 50
    }
  ])
