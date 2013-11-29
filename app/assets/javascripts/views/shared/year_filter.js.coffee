class Visio.Views.YearFilterView extends Backbone.View

  className: 'year-filter'

  template: JST['shared/year_filter']

  initialize: (options) ->

    @render()

  events:
    'click .year': 'onClickYear'
    'click .current-year': 'onClickCurrentYear'

  render: () ->
    @$el.html @template(years: Visio.manager.get('yearList'))
    @

  onClickYear: (e) ->
    year = +$(e.currentTarget).attr('data-year')
    Visio.manager.setYear(year)
    @$el.find('.current-year').text year
    @$el.find('.dropdown').toggleClass('zero-height')

  onClickCurrentYear: (e) ->
    @$el.find('.dropdown').toggleClass('zero-height')

