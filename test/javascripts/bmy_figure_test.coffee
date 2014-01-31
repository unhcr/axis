module 'BMY Figure',
  setup: ->
    @budgets = Fixtures.budgets
    Visio.user = new Visio.Models.User()
    Visio.manager = new Visio.Models.Manager()
    @figure = Visio.Figures.bmy(
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
    @d.selectedBudgetData.restore()

test 'filtered', ->

  memo = @figure.filtered @budgets.models

  strictEqual memo.length, 2, 'Should have two lines'
  ok _.find memo, ((array) -> array.budgetType == Visio.Budgets.ADMIN), 'One line should have ADMIN type'
  ok _.find memo, ((array) -> array.budgetType == Visio.Budgets.PROJECT), 'One line should have PROJECT type'

  lineData = _.find memo, (array) -> array.budgetType == Visio.Budgets.ADMIN
  strictEqual lineData.length, 2, 'Should have two datums'
  strictEqual _.where(lineData, { year: 2012 }).length, 1, 'One should be from 2012'
  strictEqual _.where(lineData, { year: 2013 }).length, 1, 'One should be from 2013'


test 'render', ->
  @figure.data @budgets.models
  @figure()

  strictEqual $(@figure.el()).find('.budget-line').length, 2, 'Should have drawn 2 budget lines'
