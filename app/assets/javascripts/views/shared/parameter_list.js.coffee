class Visio.Views.ParameterListView extends Backbone.View

  template: JST['parameter_list/list']

  className: 'parameter-list container full-width'

  tabs: [{
      type: Visio.Parameters.INDICATORS
      name: 'Indicators'
    }, {
      type: Visio.Parameters.PROBLEM_OBJECTIVES
      name: 'Objectives-Outputs'
    }, {
      type: Visio.Parameters.GOALS
      name: 'Goals'
    }, {
      type: Visio.Parameters.PPGS
      name: 'PPG'
    }]

  minItems: 10

  events:
    'click .tab': 'onClickTab'
    'focus .parameter-search': 'onFocusSearch'
    'blur .parameter-search': 'onBlurSearch'

  initialize: (options) ->

    @type = options.type

    @render()

  render: () ->
    @$el.html @template(
      plan: @model.toJSON()
      tabs: @tabs
      tab: _.findWhere(@tabs, { type: @type })
    )

    @items(@type)

    @

  onClickTab: (e) ->
    $target = $(e.currentTarget)
    @switchTab($target.attr('data-type'))

  onFocusSearch: (e) ->
    $(e.currentTarget).addClass('full-width')

  onBlurSearch: (e) ->
    $(e.currentTarget).removeClass('full-width')

  switchTab: (type) ->
    window.router.navigate("/#{@model.id}/#{type}")

    @$el.find('.selected').removeClass('selected')
    @$el.find(".#{type}").addClass('selected')

    tab = _.findWhere(@tabs, { type: type })

    @$el.find('.parameter-search').attr('placeholder', "Search #{tab.name}")

    @items(type)

  items: (type) ->
    @type = type
    items = []

    if (@model.get(type).length < @minItems && @model.get("#{type}_count") >= 10) ||
       (@model.get(type).length == 0 && @model.get("#{type}_count") > 0)
      @model.fetchParameter(type).done(() =>
        items = @model.get(type).map(@item)
        @$el.find('.items').html items.join(' ')
      )
    else
      items = @model.get(type).map(@item)
      @$el.find('.items').html items.join(' ')

  item: (parameter, index) =>
    if index > @minItems
      return
    JST['parameter_list/item'](
      parameter: parameter.toJSON())



