class Visio.Views.YearFilterView extends Backbone.View

  className: 'year-filter map-filter'

  template: HAML['shared/year_filter']

  initialize: (options) ->

    @render()

  render: () ->
    @$el.html @template({ years: Visio.manager.get('yearList') })
    $selects = @$el.find('select')

    $selects.easyDropDown
      cutOff: 10,
      wrapperClass: 'dropdown dropdown-black'
      onChange: @onChangeYear

    @

  onChangeYear: (selected) ->
    attribute = selected.value.split(Visio.Constants.SEPARATOR)[0]
    year = selected.value.split(Visio.Constants.SEPARATOR)[1]
    Visio.manager.year year
