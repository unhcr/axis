class Visio.Views.NavigationView extends Backbone.View

  template: HAML['shared/navigation']

  initialize: () ->


  events:
    'click .open': 'onClickOpen'
    'click .deselect': 'onDeselect'
    'change .visio-checkbox input': 'onChangeSelection'

  render: () ->
    _.each @searches, (searchView) -> searchView.close() if @searches?

    @searches = _.map _.values(Visio.Parameters), (hash) ->
      new Visio.Views.ParameterSearch({ collection: Visio.manager.get(hash.plural) })

    parameters = []

    _.each _.values(Visio.Parameters), (hash) ->

      # Skip if it is operation dashboard then don't include the operation in the navigation
      return if Visio.manager.get('dashboard').name == hash

      data = Visio.manager.get(hash.plural)

      parameters.push
        data: data
        hash: hash

    @$el.html @template(
      dashboard: Visio.manager.get('dashboard')
      parameters: parameters)

    _.each @searches, (view) =>
      plural = view.collection.name.plural
      $target = @$el.find(".ui-accordion-content.#{plural}")
      $target.prepend view.render().el


  onChangeSelection: (e) ->
    $target = $(e.currentTarget)

    typeid = $target.val().split(Visio.Constants.SEPARATOR)

    type = typeid[0]
    id = typeid[1]

    dashboard = Visio.manager.get('dashboard')
    # Hack for singular form of parameter
    singular = type.slice(0,  -1)

    if dashboard.include(singular, id) or
        Visio.manager.get(type).get(id)?.get('loaded') or
        id == Visio.Constants.ANY_STRATEGY_OBJECTIVE

      if $target.is(':checked')
        Visio.manager.get('selected')[type][id] = true
      else
        delete Visio.manager.get('selected')[type][id]

      Visio.manager.trigger 'change:selected', type

    else
      # Need to load external parameters, equivalent to search
      search = _.find @searches, (s) -> s.parameter().plural is type
      search.add id


  onClickOpen: (e) ->
    type = $(e.currentTarget).attr('data-type')
    @open(type)

  onDeselect: (e) ->
    type = $(e.currentTarget).attr('data-type')
    @$el.find(".#{type} input").prop 'checked', false

    # Clear out any selection
    Visio.manager.get('selected')[type] = {}

    Visio.manager.trigger 'change:selected', type

  open: (type) =>
    $opened = @$el.find('.ui-accordion-content.opened')
    if $opened.attr('data-type') == type
      $opened.toggleClass('opened')
    else
      $opened.removeClass('opened')
      @$el.find(".ui-accordion-content.#{type}").addClass('opened')

  close: ->
    @unbind()
    @remove()


