class Visio.Views.NavigationView extends Backbone.View

  template: JST['shared/navigation']

  initialize: () ->
    # Set defaults for selected
    Visio.manager.resetSelected()

  events:
    'click .open': 'onClickOpen'
    'change .visio-check input': 'onChangeSelection'

  render: () ->

    @$el.html(@template(
      strategy: Visio.manager.strategy()
      parameters: [
        {
          data: new Visio.Collections.Plan(Visio.manager.strategy().plans().where({ year: Visio.manager.year() }))
          name: 'Operations'
          type: Visio.Parameters.PLANS
        },
        {
          data: Visio.manager.strategy().ppgs()
          name: 'PPGs'
          type: Visio.Parameters.PPGS
        },
        {
          data: Visio.manager.strategy().goals()
          name: 'Goals'
          type: Visio.Parameters.GOALS
        },
        {
          data: Visio.manager.strategy().problem_objectives()
          name: 'Objectives'
          type: Visio.Parameters.PROBLEM_OBJECTIVES
        },
        {
          data: Visio.manager.strategy().outputs()
          name: 'Outputs'
          type: Visio.Parameters.OUTPUTS
        },
        {
          data: Visio.manager.strategy().indicators()
          name: 'Indicators'
          type: Visio.Parameters.INDICATORS
        }
      ]))

  onChangeSelection: (e) ->
    $target = $(e.currentTarget)

    typeid = $target.val().split('__')

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


