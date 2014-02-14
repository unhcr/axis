module 'BMY Figure',
  setup: ->
    @budgets = Fixtures.budgets
    Visio.user = new Visio.Models.User()
    Visio.manager = new Visio.Models.Manager()
    @figure = new Visio.Figures.Bmy(
      showTotal: false
      margin:
        left: 0
        right: 0
        top: 0
        bottom: 0
      width: 100
      height: 100)
    @d = new Visio.Models.Output({ id: 1 })
    sinon.stub @d, 'selectedBudgetData', -> @budgets
  teardown: ->
    @figure.unsubscribe()
    @d.selectedBudgetData.restore()

test 'filtered', ->

  memo = @figure.filtered @budgets

  strictEqual memo.length, 3, 'Should have two lines'
  ok _.find memo, ((array) -> array.budgetType == Visio.Budgets.ADMIN), 'One line should have ADMIN type'
  ok _.find memo, ((array) -> array.budgetType == Visio.Budgets.PROJECT), 'One line should have PROJECT type'
  ok _.find memo, ((array) -> array.budgetType == 'total'), 'One line should have total type'

  lineData = _.find memo, (array) -> array.budgetType == Visio.Budgets.ADMIN
  strictEqual lineData.length, 2, 'Should have two datums'
  strictEqual _.where(lineData, { year: 2012 }).length, 1, 'One should be from 2012'
  strictEqual _.where(lineData, { year: 2013 }).length, 1, 'One should be from 2013'


test 'render', ->
  @figure.collectionFn @budgets
  @figure.render()

  strictEqual $(@figure.el).find('.budget-line').length, 3, 'Should have drawn 3 budget lines'

test 'select', ->
  @figure.isExport = true
  @figure.subscribe()
  @figure.collectionFn @budgets
  @figure.render()
  i = 0

  strictEqual d3.select(@figure.el).selectAll('.active').size(), 0, 'Should have no active elements'

  $.publish("select.#{@figure.figureId()}.figure", [@figure.filtered(@budgets)[i], i])
  strictEqual d3.select(@figure.el).selectAll('.active').size(), 1, 'Should have one active elements'

  $.publish("select.#{@figure.figureId()}.figure", [@figure.filtered(@budgets)[i], i])
  strictEqual d3.select(@figure.el).selectAll('.active').size(), 0, 'Should have no active elements'
