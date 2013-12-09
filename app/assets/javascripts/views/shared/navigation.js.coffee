class Visio.Views.NavigationView extends Backbone.View

  template: JST['shared/navigation']

  initialize: () ->
    # Set defaults for selected
    _.each Visio.Types, (type) ->
      if type != Visio.Parameters.PLANS
        Visio.manager.get('selected')[type] = Visio.manager.strategy().get("#{type}_ids")
      else
        plans = Visio.manager.plans({ year: Visio.manager.year() })

        Visio.manager.get('selected')[type] = _.intersection(Visio.manager.strategy().get("#{type}_ids"), plans.pluck('id'))


  events:
    'click .open': 'onClickOpen'
    'change .visio-check input': 'onChangeSelection'

  render: () ->

    @$el.html(@template(
      strategy: Visio.manager.strategy()
      parameters: [
        {
          data: Visio.manager.plans({ year: Visio.manager.year() })
          name: 'Operations'
          type: Visio.Parameters.PLANS
        },
        {
          data: Visio.manager.get('ppgs')
          name: 'PPGs'
          type: Visio.Parameters.PPGS
        },
        {
          data: Visio.manager.get('goals')
          name: 'Goals'
          type: Visio.Parameters.GOALS
        },
        {
          data: Visio.manager.get('problem_objectives')
          name: 'Objectives'
          type: Visio.Parameters.PROBLEM_OBJECTIVES
        },
        {
          data: Visio.manager.get('outputs')
          name: 'Outputs'
          type: Visio.Parameters.OUTPUTS
        },
        {
          data: Visio.manager.get('indicators')
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
      Visio.manager.get('selected')[type] = _.union(Visio.manager.get('selected')[type], [id])
    else
      Visio.manager.get('selected')[type] = _.difference(Visio.manager.get('selected')[type], [id])

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


