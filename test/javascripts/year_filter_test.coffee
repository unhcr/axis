module 'YearFilter',
  setup: ->
    Visio.manager = new Visio.Models.Manager()

test 'render', ->
  view = new Visio.Views.YearFilterView()

  strictEqual view.$el.find('option').length, Visio.manager.get('yearList').length

test 'change year', ->
  view = new Visio.Views.YearFilterView()


  view.$el.find('li:first').trigger('click')
  strictEqual Visio.manager.year(), Visio.manager.get('yearList')[0]

  view.$el.find('li:last').trigger('click')
  strictEqual Visio.manager.year(), Visio.manager.get('yearList')[Visio.manager.get('yearList').length - 1]



