class Visio.Views.YearFilterView extends Backbone.View

  className: 'year-filter map-filter'

  template: JST['shared/year_filter']

  initialize: (options) ->

    @render()

  render: () ->
    @$el.html @template(years: Visio.manager.get('yearList'))
    $selects = @$el.find('select')

    $selects.easyDropDown
      cutOff: 10,
      wrapperClass: 'dropdown'
      onChange: @onChangeYear

    @

  onChangeYear: (selected) ->
    attribute = selected.value.split(':')[0]
    value = selected.value.split(':')[1]
    Visio.manager.set attribute, value
