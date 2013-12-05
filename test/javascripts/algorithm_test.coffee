module 'Algorithms'


test 'situation analysis', () ->
  data = new Visio.Collections.IndicatorDatum([
    {
      id: 1
      yer: 20
      myr: 8
      threshold_green: 10
      threshold_red: 5
    },
    {
      id: 2
      yer: 30
      myr: 21
      threshold_green: 40
      threshold_red: 20
    },
  ])

  color = Visio.Algorithms.situation_analysis(data, 'yer')
  strictEqual color, Visio.Algorithms.ALGO_RESULTS.success

  color = Visio.Algorithms.situation_analysis(data, 'myr')
  strictEqual color, Visio.Algorithms.ALGO_RESULTS.ok

