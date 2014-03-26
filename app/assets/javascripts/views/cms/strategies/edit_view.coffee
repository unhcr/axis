class Visio.Views.StrategyCMSEditView extends Backbone.View

  template: HAML['cms/strategies/edit']

  events:
    'click .commit': 'onCommit'

  cascadingParameters: [
    Visio.Parameters.GOALS,
    Visio.Parameters.PROBLEM_OBJECTIVES,
    Visio.Parameters.OUTPUTS,
    Visio.Parameters.INDICATORS,
  ]

  initialize: ->

    @form = new Visio.Views.Form
      model: @model
      template: HAML['shared/form_custom/cms']
      nestedTemplate: HAML['shared/form_custom/nested']

    @form.on 'initialize:operations', (form, formModel, formField, modelField) =>
      modelField.fetch().done =>
        form.render()

      related = @getRelatedParameters formField

      # Load selected
      NProgress.start()
      _.each related.cascade, (cascadeParameter) =>
        @fetchRelatedParameter(form, formModel, Visio.Parameters.OPERATIONS, cascadeParameter).done ->
          NProgress.done()

    @form.on 'close:strategy_objectives', (form) ->
      form.render()

    @form.on 'save', (form, formModel) =>
      @model.save().done (response, msg, xhr) =>
        if msg == 'success'
          model = new Visio.Models.Strategy response.strategy
          @collection.add model, merge: true
          notification = new Visio.Views.Success
            title: 'Saved'
            description: 'Strategy has successfully been saved.'

          Visio.router.navigate '/', { trigger: true }
        else
          alert(msg)

    @form.on 'close', =>
      Visio.router.navigate '/', { trigger: true }

    @form.on 'change:operations reset:operations', (form, formModel, formField, modelField) =>
      related = @getRelatedParameters formField

      NProgress.start()
      _.each related.cascade, (cascadeParameter) =>
        @fetchRelatedParameter(form, formModel, Visio.Parameters.OPERATIONS, cascadeParameter, true).done ->
          NProgress.done()

    @form.on 'change:name', (form, formField, modelField, value) ->
      if value
        form.$el.find('h2.name').text value
      else
        form.$el.find('h2.name').html '&nbsp;'

    @form.on 'change:strategy_objectives:name', (form, nestedForm, nestedModel, formField, modelField, value) ->
      if value
        nestedForm.$el.find('h2.name').text value
      else
        nestedForm.$el.find('h2.name').html '&nbsp;'

    _.each @cascadingParameters, (parameter) =>

      @form.on "initialize:strategy_objectives:#{parameter.plural}", (form, nestedForm, nestedModel, formField, modelField) =>

        if formField.get('name') == Visio.Parameters.GOALS.plural
          modelField.fetch().done ->
            form.render()

        related = @getRelatedParameters formField

        # Load selected
        _.each related.cascade, (cascadeParameter) =>
          @fetchRelatedParameter nestedForm, nestedModel, parameter, cascadeParameter

      @form.on ["change:strategy_objectives:#{parameter.plural}",
                "reset:strategy_objectives:#{parameter.plural}"].join(' '),
        (form, nestedForm, nestedModel, formField, modelField, value, model) =>

          related = @getRelatedParameters formField

          _.each related.cascade, (cascadeParameter) =>
            @fetchRelatedParameter nestedForm, nestedModel, parameter, cascadeParameter

    @form.initSchema()

  fetchRelatedParameter: (form, formModel, parameter, relatedParameter, select = false) ->
    # Have this function return a promise
    dfd = new $.Deferred()

    # Need to load based on all its dependents
    field = form.fields.findWhere { name: parameter.plural }
    relatedFormField = form.fields.findWhere { name: relatedParameter.plural }
    dependent = @getRelatedParameters(relatedFormField).dependent

    collection = formModel.get relatedParameter.plural

    if select
      unselected = new Visio.Collections[relatedParameter.className](
        collection.filter (model) -> not relatedFormField.selected(model.id))

    collection.reset []

    resolved = _.map dependent, -> false
    # When we fetch related paramter, we have to make sure to fetch each dependent parameter since we
    # recompute parameter
    _.each dependent, (dependentParameter, idx, list) ->
      join_ids = {}
      dependentField = form.fields.findWhere { name: dependentParameter.plural }

      # Weird thing where data doesn't get passed in backbone if empty
      if _.isEmpty dependentField.getSelected()
        collection.set [], { remove: false }
        form.render()
        resolved[idx] = true
        if _.every(resolved, (value) -> value)
          dfd.resolve collection
        return


      join_ids["#{dependentParameter.singular}_ids"] = dependentField.getSelected()
      data = { join_ids: join_ids }

      collection.fetch({ data: data, remove: false }).done ->
        if select
          collection.each (model) ->
            relatedFormField.selected model.id, true unless unselected.get(model.id)?
        form.render()

        resolved[idx] = true
        if _.every(resolved, (value) -> value)
          dfd.resolve collection

    dfd.promise()

  getRelatedParameters: (formField) ->
    switch formField.get 'name'
      when Visio.Parameters.GOALS.plural
        {
          dependent: [],
          cascade: [Visio.Parameters.PROBLEM_OBJECTIVES]
        }
      when Visio.Parameters.PROBLEM_OBJECTIVES.plural
        {
          dependent: [Visio.Parameters.GOALS],
          cascade: [Visio.Parameters.OUTPUTS, Visio.Parameters.INDICATORS]
        }
      when Visio.Parameters.OUTPUTS.plural
        {
          dependent: [Visio.Parameters.PROBLEM_OBJECTIVES],
          cascade: [Visio.Parameters.INDICATORS]
        }
      when Visio.Parameters.INDICATORS.plural
        {
          dependent: [Visio.Parameters.OUTPUTS, Visio.Parameters.PROBLEM_OBJECTIVES],
          cascade: []
        }
      when Visio.Parameters.OPERATIONS.plural
        {
          dependent: [],
          cascade: [Visio.Parameters.PPGS]
        }
      when Visio.Parameters.PPGS.plural
        {
          dependent: [Visio.Parameters.OPERATIONS],
          cascade: []
        }

  render: ->
    @$el.html @form.render().el
    @

  close: ->
    @form.close()
    @unbind()
    @remove()



