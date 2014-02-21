module 'Circle',
  setup: ->
    @circle = new Visio.Figures.Circle
      margin:
        top: 0
        bottom: 0
        left: 0
        right: 0
      width: 100
      height: 100
      number: 45
      percent: Math.random()

test 'number', ->
  @circle.numberFn(15)
  n = @circle.numberFn()

  strictEqual n, 15

test 'render', ->

  @circle.render()

  ok $(@circle.el).find '.background'
  ok $(@circle.el).find '.foreground'

