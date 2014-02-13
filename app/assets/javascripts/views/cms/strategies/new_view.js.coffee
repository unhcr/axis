class Visio.Views.StrategyCMSEditView extends Backbone.View

  template: HAML['cms/strategies/edit']

  events:
    'click .commit': 'onCommit'

  initialize: ->
    @form = new Backbone.Form
      model: @model

    Visio.manager.get('operations').fetchSynced().done =>
      @form.fields.operations.editor.setOptions Visio.manager.get('operations')

      @form.fields.operations.editor.setSelected(
        @selectedIndexes Visio.manager.get('operations'), @model.get('operations'))

    @render()

  render: ->

    @$el.html @template()
    @$el.find('.form').html @form.render().el
    @form.fields.strategy_objectives.editor.form.on 'open', (editor) =>
      modalForm = editor.modalForm

      # These fields depend on each other
      cascadingFields = [
        {
          field: Visio.Parameters.GOALS,
          dependent: [],
          cascade: [Visio.Parameters.PROBLEM_OBJECTIVES]
        },
        {
          field: Visio.Parameters.PROBLEM_OBJECTIVES,
          dependent: [Visio.Parameters.GOALS],
          cascade: [Visio.Parameters.OUTPUTS, Visio.Parameters.INDICATORS]
        },
        {
          field: Visio.Parameters.OUTPUTS,
          dependent: [Visio.Parameters.PROBLEM_OBJECTIVES],
          cascade: [Visio.Parameters.INDICATORS]
        },
        {
          field: Visio.Parameters.INDICATORS,
          dependent: [Visio.Parameters.OUTPUTS, Visio.Parameters.PROBLEM_OBJECTIVES],
          cascade: []
        }
      ]

      _.each cascadingFields, (field, idx, list) =>
        # Set initial selected
        formField = modalForm.fields[field.field.plural]

        collection = new Visio.Collections[field.field.className]()

        # Should show items if they are selected (exception is first since we always show all)
        data = join_ids: {}
        isPreviousSelection = false

        for dependentField in field.dependent
          data.join_ids["#{dependentField.singular}_ids"] =
            _.map modalForm.fields[dependentField.plural].value, (modelOrId) ->
              modelOrId.id || modelOrId


        if idx == 0 or _.any(_.values(data.join_ids), (joinArray) -> joinArray.length > 0)
          collection.fetch(data: data).done =>
            formField.editor.setOptions (callback) -> callback(collection)
            selected = new Visio.Collections[field.field.className](
              _.map(formField.value, (modelOrId) ->
                if _.isObject(modelOrId) then return modelOrId else return modelOrId))
            formField.editor.setSelected @selectedIndexes(collection, selected)
        else
          formField.editor.setOptions (callback) -> callback(collection)

        return unless field.cascade.length > 0



        # Setup cascading selection
        modalForm.on "#{field.field.plural}:change", =>
          return unless field.cascade.length > 0

          collections = {}

          for cascadingField in field.cascade
            dependentFields = (_.find cascadingFields, (field) -> field.field == cascadingField).dependent
            ids = {}
            for dependentField in dependentFields
              ids[dependentField.plural] = modalForm.fields[dependentField.plural].getValue()

            collections[cascadingField.plural] = new Visio.Collections[cascadingField.className]()

            modalForm.fields[cascadingField.plural].editor.setOptions (callback) =>
              followingFormField = modalForm.fields[cascadingField.plural]
              selected = new Visio.Collections[cascadingField.className](followingFormField.value)
              if _.isEmpty(ids) or _.every(_.values(ids), (idArray) -> _.isEmpty idArray )
                callback(collections[cascadingField.plural])
                followingFormField.editor.setSelected @selectedIndexes(collections[cascadingField.plural], selected)
              else

                for dependentField in dependentFields
                  continue if _.isEmpty ids[dependentField.plural]
                  data = join_ids: {}
                  data.join_ids["#{dependentField.singular}_ids"] = ids[dependentField.plural]

                  # Wrap in closure so that done function properly refers to correct field
                  ((type) =>
                    collections[type].fetch(data: data, remove: false).done (response) =>
                      console.log type
                      callback collections[type]
                      followingFormField.editor.setSelected @selectedIndexes(collections[type], selected)
                  )(cascadingField.plural)

  onCommit: ->
    @model.save(strategy: @form.getValue()).done (response, msg, xhr) =>
      if msg == 'success'
        @collection.add response.strategy
        Visio.router.navigate '/', { trigger: true }
      else
        alert(msg)

  selectedIndexes: (collection, selectedCollection) ->
    selectedIndexes = []
    ids = collection.pluck 'id'

    selectedCollection.each (model) ->
      selectedIndexes.push ids.indexOf(model.id)

    selectedIndexes

  close: ->
    @unbind()
    @remove()



