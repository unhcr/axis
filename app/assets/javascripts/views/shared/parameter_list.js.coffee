class Visio.Views.ParameterListView extends Backbone.View

  template: HAML['parameter_list/list']

  className: 'parameter-list container full-width overlay'

  tabs: [
      Visio.Parameters.INDICATORS,
      Visio.Parameters.OUTPUTS,
      Visio.Parameters.PROBLEM_OBJECTIVES,
      Visio.Parameters.GOALS,
      Visio.Parameters.PPGS
    ]

  minItems: 10

  events:
    'click .tab': 'onClickTab'
    'focus .parameter-search': 'onFocusSearch'
    'blur .parameter-search': 'onBlurSearch'
    'click .close' : 'onClickClose'
    'keyup .parameter-search': 'onParameterSearch'

  initialize: (options) ->

    @type = options.type

    @render()

  render: () ->
    @$el.html @template(
      plan: @model.toJSON()
      tabs: @tabs
      selectedTab: _.findWhere(@tabs, { plural: @type })
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
    Visio.router.navigate "/#{@model.id}/#{type}"

    @$el.find('.selected').removeClass('selected')
    @$el.find(".#{type}").addClass('selected')

    tab = _.findWhere(@tabs, { plural: type })

    @$el.find('.parameter-search').attr 'placeholder', "Search #{tab.human}"

    @items(type)

  items: (type) ->
    @type = type
    items = []

    if @model.get("#{type}_count") < @minItems
      @$el.find('.parameter-search').addClass('zero-width')
    else
      @$el.find('.parameter-search').removeClass('zero-width')

    if (@model.get(type).length == 0 && @model.get("#{type}_count") > 0)
      @model.fetchParameter(type).done(() =>
        items = @model.get(type).map(@item)
        @$el.find('.items').html items.join(' ')
      )
    else
      items = @model.get(type).map(@item)
      @$el.find('.items').html items.join(' ')

  item: (parameter, index) =>
    HAML['parameter_list/item'](parameter: parameter)

  onParameterSearch: (e) =>
    query = $(e.currentTarget).val()
    parameters = @search(query)

    items = parameters.map(@item)
    @$el.find('.items').html items.join(' ')


  search: (query) =>
    re = new RegExp('.*' + query.split('').join('.*') + '.*', 'g')

    @model.get(@type).filter((parameter) ->
      name = parameter.toString()
      return name.search(re) != -1
    )

  onClickClose: (e) ->
    @close()

  close: () ->
    Visio.router.navigate('/')
    @unbind()
    @remove()



