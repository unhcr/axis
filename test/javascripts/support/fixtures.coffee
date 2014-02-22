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

@Fixtures.topo = {
  "type": "Topology",
  "transform": {
    "scale": [0.0005000500050005, 0.00010001000100010001],
    "translate": [100, 0]
  },
  "objects": {
    "world_50m": {
      "type": "GeometryCollection",
      "geometries": [
        {
          "type": "Point",
          "properties": {
            "adm0_a3": "BEN"
          },
          "coordinates": [4000, 5000]
        },
        {
          "type": "LineString",
          "properties": {
            "adm0_a3": "ABC",
            "prop1": 0
          },
          "arcs": [0]
        },
        {
          "type": "Polygon",
          "properties": {
            "adm0_a3": "DEF",
            "prop1": {
              "this": "that"
            }
          },
          "arcs": [[1]]
        }
      ]
    }
  },
  "arcs": [
    [[4000, 0], [1999, 9999], [2000, -9999], [2000, 9999]],
    [[0, 0], [0, 9999], [2000, 0], [0, -9999], [-2000, 0]]
  ]
}
