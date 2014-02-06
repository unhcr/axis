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
