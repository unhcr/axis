class Visio.Views.StrategyCMSNewView extends Backbone.View

  template: JST['cms/strategies/edit']

  events:
    'click .commit': 'onCommit'

  initialize: ->
    @form = new Backbone.Form
      model: @model

    @model.operations.fetchSynced().done =>
      @form.fields.operations.editor.setOptions @model.operations

    @render()

  render: ->

    @$el.html @template()
    @$el.find('.form').html @form.render().el
    @form.fields.strategy_objectives.editor.form.on 'open', (editor) ->
      modalForm = editor.modalForm

      # These fields depend on each other
      cascadingFields = [
        Visio.Parameters.GOALS,
        Visio.Parameters.PROBLEM_OBJECTIVES,
        Visio.Parameters.OUTPUTS,
        Visio.Parameters.INDICATORS,
      ]

      _.each cascadingFields, (field, idx, list) ->
        modalForm.on "#{field.plural}:change", ->
          ids = modalForm.fields[field.plural].getValue()
          followingField = list[idx + 1]
          return unless followingField
          collection = new Visio.Collections[followingField.className]()

          modalForm.fields[followingField.plural].editor.setOptions (callback) ->
            if _.isEmpty(ids)
              callback(collection)
            else
              data = { join_ids: {} }
              data.join_ids["#{field.singular}_ids"] = ids

              collection.fetch(data: data).done ->
                callback(collection)

  onCommit: ->
    @model.save(strategy: @form.getValue()).done (response, msg, xhr) ->
      if msg == 'success'
        Visio.router.navigate '/', { trigger: true }
      else
        alert(msg)



