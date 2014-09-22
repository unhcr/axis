module 'BMY Figure',
  setup: ->
    @budgets = Fixtures.budgets
    Visio.user = new Visio.Models.User()
    Visio.manager = new Visio.Models.Manager()
    @figure = new Visio.Figures.Bmy(
      showTotal: true
      margin:
        left: 0
        right: 0
        top: 0
        bottom: 0
      width: 100
      height: 100)
    sinon.stub Visio.Models.Output.prototype, 'selectedBudgetData', => @budgets
    @d = new Visio.Models.Output({ id: 1 })

  teardown: ->
    @figure.unsubscribe()
    Visio.Models.Output.prototype.selectedBudgetData.restore()

test 'filtered', ->
  @figure.filters.get('scenario').filter(Visio.Scenarios.AOL, true)
  @figure.filters.get('scenario').filter(Visio.Scenarios.OL, true)

  memo = @figure.filtered @d

  strictEqual memo.length, 3, 'Should have three lines'
  ok _.find memo, ((array) -> array[array.groupBy] == Visio.Budgets.ADMIN), 'One line should have ADMIN type'
  ok _.find memo, ((array) -> array[array.groupBy] == Visio.Budgets.PROJECT), 'One line should have PROJECT type'
  ok _.find memo, ((array) -> array[array.groupBy] == 'total'), 'One line should have total type'

  lineData = _.find memo, (array) -> array[array.groupBy] == Visio.Budgets.ADMIN
  strictEqual lineData.length, 2, 'Should have two datums'
  strictEqual _.where(lineData, { year: 2012 }).length, 1, 'One should be from 2012'
  strictEqual _.where(lineData, { year: 2013 }).length, 1, 'One should be from 2013'

test 'filtered - no total', ->
  @figure.filters.get('scenario').filter Visio.Scenarios.AOL, true, { silent: true }
  @figure.filters.get('scenario').filter Visio.Scenarios.OL, true, { silent: true }
  @figure.filters.get('show_total').filter 'Show Total', false, { silent: true }

  memo = @figure.filtered @d

  strictEqual memo.length, 2, 'Should have two lines'
  ok _.find memo, ((array) -> array[array.groupBy] == Visio.Budgets.ADMIN), 'One line should have ADMIN type'
  ok _.find memo, ((array) -> array[array.groupBy] == Visio.Budgets.PROJECT), 'One line should have PROJECT type'

test 'render', ->
  @figure.filters.get('scenario').filter(Visio.Scenarios.AOL, true)
  @figure.filters.get('scenario').filter(Visio.Scenarios.OL, true)
  @figure.collectionFn @d
  @figure.render()

  strictEqual $(@figure.el).find('.budget-line').length, 3, 'Should have drawn 3 budget lines'

test 'select', ->
  @figure.isExport = true
  @figure.subscribe()
  @figure.modelFn @d
  @figure.render()
  i = 0

  strictEqual d3.select(@figure.el).selectAll('.active').size(), 0, 'Should have no active elements'

  $.publish("active.#{@figure.figureId()}.figure", [@figure.filtered(@d)[i], i])
  strictEqual d3.select(@figure.el).selectAll('.active').size(), 1, 'Should have one active elements'

  $.publish("active.#{@figure.figureId()}.figure", [@figure.filtered(@d)[i], i])
  strictEqual d3.select(@figure.el).selectAll('.active').size(), 0, 'Should have no active elements'
