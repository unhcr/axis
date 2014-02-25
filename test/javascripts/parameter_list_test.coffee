module 'ParameterListView',

  setup: () ->
    Visio.manager = new Visio.Models.Manager()
    Visio.manager.get('plans').reset([{ name: 'Ben', id: 'abcd', operation_name: 'Lisa' }])

test 'search', () ->
  plan = Visio.manager.get('plans').at(0)
  plan.get('indicators').reset([{
      name: 'babf'
    },
    {
      name: 'yaybycy'
    },
    {
      name: 'efg'
    }])
  view = new Visio.Views.ParameterListView({
    model: plan
    type: Visio.Parameters.INDICATORS.plural
  })

  models = view.search('abc')

  strictEqual(1, models.length)
  strictEqual('yaybycy', models[0].get('name'))

  models = view.search('ab')
  strictEqual(2, models.length)

  models = view.search('hhh')
  strictEqual(0, models.length)
