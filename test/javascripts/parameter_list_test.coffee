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

  # Ensure we don't make call to render since we do not want to make ajax call
  sinon.stub Visio.Views.ParameterListView.prototype, 'render', () ->

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

  Visio.Views.ParameterListView.prototype.render.restore()
