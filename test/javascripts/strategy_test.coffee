module 'Strategy'

test('include parameter', () ->
  strategy = new Visio.Models.Strategy({
    'indicators_ids': ['a', 'b', 'c']

  })

  i = new Visio.Models.Indicator({
    id: 'b'
  })

  ok(strategy.include(Visio.Parameters.INDICATORS, i.id))

  i = new Visio.Models.Indicator({
    id: 'd'
  })

  ok(!strategy.include(Visio.Parameters.INDICATORS, i.id))
)


