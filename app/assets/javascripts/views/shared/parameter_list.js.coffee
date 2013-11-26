class Visio.Views.ParameterListView extends Backbone.View

  template: JST['parameter_list/list']

  className: 'parameter-list container'

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

  initialize: (options) ->

    @type = options.type

    @render()

  render: () ->
    @$el.html @template(
      plan: @model.toJSON()
      tabs: @tabs
      type: @type
    )

    @content(@type)

    @

  content: (type) ->
    @type = type
    items = []

    if @model.get(type).length < @minItems && @model.get("#{type}_count") >= 10
      @model.fetchParameter(type).done(() =>
        items = @model.get(type).map(@item)
        @$el.find('.content').html items.join(' ')
      )
    else
      items = @model.get(type).map(@item)
      @$el.find('.content').html items.join(' ')

  item: (parameter, index) =>
    if index > @minItems
      return
    JST['parameter_list/item'](
      parameter: parameter.toJSON())



