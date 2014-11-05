module 'Figure Filter',
  setup: ->
    @budgets = Fixtures.budgets
    @data = Fixtures.data

    @filters = new Visio.Collections.FigureFilter([
      {
        filterType: 'checkbox'
        id: 'budget_type'
        values: { ADMIN: true, PROJECT: false}
      },
      {
        filterType: 'radio'
        id: 'year'
        values: {
          '2012': false, '2013': true
        }

      },
      {
        filterType: 'radio'
        id: 'is_performance'
        values: {
          'true': true
          'false': false
        }
      }
    ])

test 'Filters', ->

  filtered = @data.filter (d) => not @filters.isFiltered(d)
  strictEqual filtered.length, 2, 'There should be two impact indicators'
  ok _.find(filtered, (d) -> d.id == 'jeff')
  ok _.find(filtered, (d) -> d.id == 'lisa')

  filtered = @budgets.filter (d) => not @filters.isFiltered(d)
  strictEqual filtered.length, 2, 'There should be two impact indicators'
  ok _.find(filtered, (d) -> d.id == 'g')
  ok _.find(filtered, (d) -> d.id == 'y')

test 'resetFilter', ->

  callback = sinon.spy()

  filter = @filters.get('budget_type')
  filter.set 'callback', callback

  ok filter.get('values').ADMIN
  ok not filter.get('values').PROJECT

  # should be original values
  filter.resetFilter()
  strictEqual callback.callCount, 0, "Don't call callback if nothing changed"
  ok filter.filter 'ADMIN'
  ok not filter.filter 'PROJECT'

  filter.filter 'ADMIN', false
  ok callback.calledOnce, "Should be called once and is #{callback.callCount}"
  ok not filter.filter 'ADMIN'
  ok not filter.filter 'PROJECT'

  # should be original values
  filter.resetFilter()
  ok callback.calledTwice, "Should be called twice and is #{callback.callCount}"
  ok filter.filter 'ADMIN'
  ok not filter.filter 'PROJECT'

  filter.filter 'ADMIN', false
  filter.filter 'PROJECT', false
  strictEqual callback.callCount, 4
  filter.resetFilter()
  strictEqual callback.callCount, 5

  # What if no callback
  filter.set 'callback', null
  filter.filter 'ADMIN', false
  filter.resetFilter()
  ok filter.filter 'ADMIN'
  ok not filter.filter 'PROJECT'


test 'resetFilter - collection', ->

  ok not _.every(@filters.pluck('values'), (values) ->
    _.every(_.values(values), (value) -> value)), 'Every value should not be true'

  @filters.resetFilters()

  ok not _.every(@filters.pluck('values'), (values) ->
    _.every(_.values(values), (value) -> value)), 'Every value should not be true'

  # Should not reset hidden filters
  filter = @filters.get('budget_type')
  filter.set 'hidden', true
  filter.filter 'ADMIN', false
  @filters.resetFilters()
  ok !filter.filter 'ADMIN'

test 'Callback on filter', ->
  callback = sinon.spy()

  filter = @filters.get 'budget_type'
  filter.set 'callback', callback

  filter.filter 'ADMIN', false

  strictEqual callback.callCount, 1, 'Callback should be called once'
  ok callback.calledWith('ADMIN', false), 'Callback should be called with params'

  filter.filter 'ADMIN', true, { silent: true }
  strictEqual callback.callCount, 1, 'Callback should be called once'
  ok filter.filter 'ADMIN'

test 'active', ->

  year = @filters.get('year').active()
  strictEqual year, '2013'

  types = @filters.get('budget_type').active()
  strictEqual types.length, 1
  strictEqual types[0], 'ADMIN'

