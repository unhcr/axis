class Visio.Views.YearFilterView extends Backbone.View

  template: JST['shared/year_filter']

  initialize: (options) ->

    @render()

  events:
    'click .year': 'onClickYear'

  render: () ->

    @

  onClickYear: (e) ->
    year = +$(e.currentEvent).attr('data-year')
    Visio.manager.setYear(year)

