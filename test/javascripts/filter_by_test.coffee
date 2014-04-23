module 'Filter By View',
  setup: ->
    Visio.manager = new Visio.Models.Manager()
    @figure = new Visio.Figures.Absy(
      margin:
        left: 0
        right: 0
        top: 0
        bottom: 0
      width: 100
      height: 100
      )
    @d = new Visio.Models.Output({ id: 1 })
    sinon.stub @d, 'selectedAmount', -> 10
    sinon.stub @d, 'selectedAchievement', -> { result: 10 }

    @filterBy = new Visio.Views.FilterBy { figure: @figure }

  teardown: ->
    @filterBy.close()
    @figure.close()


test 'render', ->
  @filterBy.render()

  nFilters = @figure.filters.length

  strictEqual @filterBy.$el.find('.filter-group').length, nFilters
  ok not @filterBy.$el.hasClass 'open'

  @filterBy.$el.find('.filter-toggle').trigger 'click'
  ok @filterBy.$el.find('.filters').hasClass 'open'
  ok @filterBy.$el.find('.filters').hasClass 'styled'

  ok @filterBy.transitioning, 'Should be transitioning'
  # Kill transition
  @filterBy.transitioning = false

  @filterBy.$el.find('.filter-toggle').trigger 'click'
  ok not @filterBy.$el.find('.filters').hasClass 'open', 'Should now be open'

test 'render - rerender', ->
  @filterBy.render()
  @filterBy.$el.find('.filter-toggle').trigger 'click'
  ok @filterBy.$el.find('.filters').hasClass 'open'
  ok @filterBy.$el.find('.filters').hasClass 'styled'

  @filterBy.render true
  ok @filterBy.$el.find('.filters').hasClass 'open'
  ok @filterBy.$el.find('.filters').hasClass 'styled'

  @filterBy.render()
  ok not @filterBy.$el.find('.filters').hasClass 'open'
