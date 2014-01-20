class Visio.Views.NavigationView extends Backbone.View

  template: JST['shared/navigation']

  initialize: () ->

  events:
    'click .open': 'onClickOpen'
    'change .visio-check input': 'onChangeSelection'

  render: () ->

    parameters = []

    _.each _.values(Visio.Parameters), (hash) ->
      return if hash == Visio.Parameters.STRATEGY_OBJECTIVES

      if hash == Visio.Parameters.PLANS
        data = new Visio.Collections.Plan(
          Visio.manager.strategy()[hash.plural]().where({ year: Visio.manager.year() }))
      else
        data = Visio.manager.strategy()[hash.plural]()

      parameters.push
        data: data
        hash: hash

    @$el.html @template(
      strategy: Visio.manager.strategy()
      parameters: parameters)

  onChangeSelection: (e) ->
    $target = $(e.currentTarget)

    typeid = $target.val().split(Visio.Constants.SEPARATOR)

    type = typeid[0]
    id = typeid[1]

    if $target.is(':checked')
      Visio.manager.get('selected')[type][id] = true
    else
      delete Visio.manager.get('selected')[type][id]

    Visio.manager.trigger('change:selected')

  onClickOpen: (e) ->
    type = $(e.currentTarget).attr('data-type')
    @open(type)

  open: (type) =>
    $opened = @$el.find('.ui-accordion-content.opened')
    if $opened.attr('data-type') == type
      $opened.toggleClass('opened')
    else
      $opened.removeClass('opened')
      @$el.find(".ui-accordion-content.#{type}").addClass('opened')


