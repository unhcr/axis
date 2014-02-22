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

  filter = @filters.get('budget_type')
  ok filter.get('values').ADMIN
  ok not filter.get('values').PROJECT

  filter.resetFilter()
  ok filter.get('values').ADMIN
  ok filter.get('values').PROJECT

test 'resetFilter - collection', ->

  ok not _.every(@filters.pluck('values'), (values) ->
    _.every(_.values(values), (value) -> value)), 'Every value should not be true'

  @filters.resetFilters()

  ok _.every(@filters.pluck('values'), (values) ->
    _.every(_.values(values), (value) -> value)), 'Every value should be true'

test 'Callback on filter', ->
  callback = sinon.spy()

  filter = @filters.get 'budget_type'
  filter.set 'callback', callback

  filter.filter 'ADMIN', false

  strictEqual callback.callCount, 1, 'Callback should be called once'
  ok callback.calledWith('ADMIN', false), 'Callback should be called with params'
