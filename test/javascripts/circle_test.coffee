module 'Circle',
  setup: ->
    @el = $('<div></div>')[0]
    @circle = Visio.Figures.circle(
      margin:
        top: 0
        bottom: 0
        left: 0
        right: 0
      width: 100
      height: 100
      selection: d3.select(@el)
      number: 45
      percent: Math.random()
      resultType: Visio.Algorithms.ALGO_RESULTS.success)

test 'number', ->
  @circle.number(15)
  n = @circle.number()

  strictEqual n, 15

  @circle.number('abc')
  n = @circle.number()

  strictEqual n, '?'

test 'render', ->

  @circle()

  ok $(@el).find '.background'
  ok $(@el).find '.foreground'

