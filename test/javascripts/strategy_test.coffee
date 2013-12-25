module 'Strategy'

test('include parameter', () ->
  strategy = new Visio.Models.Strategy({
    'indicator_ids': {'a':true, 'b':true, 'c':true}

  })

  i = new Visio.Models.Indicator({
    id: 'b'
  })

  ok(strategy.include(Visio.Parameters.INDICATORS.singular, i.id))

  i = new Visio.Models.Indicator({
    id: 'd'
  })

  ok(!strategy.include(Visio.Parameters.INDICATORS.singular, i.id))
)


