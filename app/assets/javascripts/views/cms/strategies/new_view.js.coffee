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
    @form.fields.strategyObjectives.editor.form.on 'open', (editor) ->
      modalForm = editor.modalForm

      modalForm.on 'goals:change', ->
        ids = modalForm.fields.goals.getValue()
        problemObjectives = new Visio.Collections.ProblemObjective()

        modalForm.fields.problem_objectives.editor.setOptions (callback) ->
          if _.isEmpty(ids)
            callback(problemObjectives)
          else
            problemObjectives.fetchSynced(
              join_ids:
                goal_ids: ids
            ).done ->
              alert(problemObjectives.length)
              callback(problemObjectives)



  onCommit: ->
    console.log 'sasd'


  save: ->
    @model.save()
