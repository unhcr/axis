class Visio.Views.SaveAsStrategy extends Backbone.View

  @include Visio.Mixins.Modal

  template: HAML['shared/save_as_strategy']

  className: 'save-as-strategy-container'

  events:
    'click .cancel': 'close'
    'click .close': 'close'
    'click .save': 'onSave'

  initialize: (options) ->
    @model = new Visio.Models.Strategy(
      _.extend Visio.manager.toStrategyParams(), { is_personal: true })

    @initModal()

  render: ->

    @$el.html @template()

    @

  onSave: (e) ->
    name = @$el.find('.strategy-name').val()
    description = @$el.find('.strategy-description').val()

    @model.set 'name', name
    @model.set 'description', description

    @save()

  save: ->
    @model.save().done (response, msg, xhr) ->
      if msg == 'success'
        notification = new Visio.Views.Success
          title: 'Saved'
          description: 'Strategy has successfully been saved.'

        Visio.manager.get('personal_strategies').add response.strategy

      else
        alert(msg)
    @close()

  close: ->
    Visio.router?.navigate Visio.Utils.generateOverviewUrl()
    @unbind()
    @remove()

