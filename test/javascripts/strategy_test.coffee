module 'Strategy'

test('include parameter', () ->
  strategy = new Visio.Models.Strategy({
    'indicators_ids': {'a':true, 'b':true, 'c':true}

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


