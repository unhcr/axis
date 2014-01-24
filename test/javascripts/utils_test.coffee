module 'Utils'

test('Parse transform', () ->
  transform = Visio.Utils.parseTransform('translate(0,1234)')
  assert.equal(0, transform.translate[0], 'X translate')
  assert.equal(1234, transform.translate[1], 'Y translate')
  assert.equal(1, transform.scale, 'Scale')

  transform = Visio.Utils.parseTransform('translate(23,1234)scale(.02329)')
  assert.equal(23, transform.translate[0], 'X translate')
  assert.equal(1234, transform.translate[1], 'Y translate')
  ok(transform.scale > .02 && transform.scale < .03, 'Scale is decimal')

  transform = Visio.Utils.parseTransform('scale(.23)')
  ok(transform.scale > .2 && transform.scale < .3)
  assert.equal(0, transform.translate[0], 'X translate')
  assert.equal(0, transform.translate[1], 'Y translate')
)

test 'humanMetric', ->
  strictEqual Visio.Utils.humanMetric(Visio.Algorithms.REPORTED_VALUES.myr), 'MYR'
  strictEqual Visio.Utils.humanMetric(Visio.Algorithms.REPORTED_VALUES.yer), 'YER'
  strictEqual Visio.Utils.humanMetric(Visio.Algorithms.REPORTED_VALUES.baseline), 'Baseline'
  strictEqual Visio.Utils.humanMetric(Visio.Algorithms.GOAL_TYPES.target), 'Target'
  strictEqual Visio.Utils.humanMetric(Visio.Algorithms.GOAL_TYPES.standard), 'Standard'
  strictEqual Visio.Utils.humanMetric('abc'), 'N/A'
