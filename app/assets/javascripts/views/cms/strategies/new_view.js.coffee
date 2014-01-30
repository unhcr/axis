class Visio.Views.StrategyCMSNewView extends Backbone.View

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
        Visio.Parameters.GOALS,
        Visio.Parameters.PROBLEM_OBJECTIVES,
        Visio.Parameters.OUTPUTS,
        Visio.Parameters.INDICATORS,
      ]

      _.each cascadingFields, (field, idx, list) =>
        # Set initial selected
        followingField = list[idx + 1]
        previousField = list[idx - 1]
        formField = modalForm.fields[field.plural]

        collection = new Visio.Collections[field.className]()

        # Should show items if they are selected (exception is first since we always show all)
        data = join_ids: {}
        isPreviousSelection = false
        if previousField
          data.join_ids["#{previousField.singular}_ids"] =
            _.map modalForm.fields[previousField.plural].value, (modelOrId) -> modelOrId.id || modelOrId
          isPreviousSelection = data.join_ids["#{previousField.singular}_ids"].length > 0

        # Nothing previously selected so just load empty (unless it's the first field)
        if isPreviousSelection or idx == 0
          collection.fetch(data: data).done =>
            formField.editor.setOptions (callback) -> callback(collection)
            selected = new Visio.Collections[field.className](
              _.map(formField.value, (modelOrId) -> if _.isObject(modelOrId) then return modelOrId else return modelOrId))
            formField.editor.setSelected @selectedIndexes(collection, selected)
        else
          formField.editor.setOptions (callback) -> callback(collection)

        return unless followingField

        # Setup cascading selection
        modalForm.on "#{field.plural}:change", =>
          ids = modalForm.fields[field.plural].getValue()
          collection = new Visio.Collections[followingField.className]()

          modalForm.fields[followingField.plural].editor.setOptions (callback) =>
            followingFormField = modalForm.fields[followingField.plural]
            selected = new Visio.Collections[followingField.className](followingFormField.value)
            if _.isEmpty(ids)
              callback(collection)
              followingFormField.editor.setSelected @selectedIndexes(collection, selected)
            else
              data = join_ids: {}
              data.join_ids["#{field.singular}_ids"] = ids

              collection.fetch(data: data).done =>
                callback(collection)
                followingFormField.editor.setSelected @selectedIndexes(collection, selected)

  onCommit: ->
    @model.save(strategy: @form.getValue()).done (response, msg, xhr) ->
      if msg == 'success'
        Visio.router.navigate '/', { trigger: true }
      else
        alert(msg)

  selectedIndexes: (collection, selectedCollection) ->
    selectedIndexes = []
    ids = collection.pluck 'id'

    selectedCollection.each (model) ->
      selectedIndexes.push ids.indexOf(model.id)

    selectedIndexes



