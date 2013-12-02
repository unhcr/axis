class Visio.Views.NavigationView extends Backbone.View

  template: JST['shared/navigation']

  initialize: () ->

  events:
    'click .open': 'onClickOpen'

  render: () ->

    # TODO only select those that are part of the strategy
    @$el.html(@template(
      strategy: Visio.manager.strategy()
      parameters: [
        {
          data: Visio.manager.plans({ year: Visio.manager.year() }).map((p) -> p.toJSON())
          name: 'Operations'
          type: Visio.Parameters.PLANS
        },
        {
          data: Visio.manager.get('ppgs').toJSON()
          name: 'PPGs'
          type: Visio.Parameters.PPGS
        },
        {
          data: Visio.manager.get('goals').toJSON()
          name: 'Goals'
          type: Visio.Parameters.GOALS
        },
        {
          data: Visio.manager.get('problem_objectives').toJSON()
          name: 'Objectives'
          type: Visio.Parameters.PROBLEM_OBJECTIVES
        },
        {
          data: Visio.manager.get('outputs').toJSON()
          name: 'Outputs'
          type: Visio.Parameters.OUTPUTS
        },
        {
          data: Visio.manager.get('indicators').toJSON()
          name: 'Indicators'
          type: Visio.Parameters.INDICATORS
        }
      ]))

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


