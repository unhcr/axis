class Visio.Views.AchievementView extends Backbone.View

  template: HAML['algorithms/achievement']

  events:
    'change #achievement_is_performance': 'onChangePerformance'
    'submit form': 'onSubmit'
    'click .run': 'onRun'

  initialize: ->
    @collection.on 'add', @addOne
    @render()

  render: ->
    @$el.html @template()
    @addAll()
    @

  addAll: ->
    @collection.each @addOne, @

  addOne: (model) =>

    view = new Visio.Views.IndicatorDatumShowView( model: model )
    @$el.find('.indicators').append view.render().el

  onChangePerformance: (e) ->
    value = +$(e.currentTarget).val()
    console.log value

    $row = @$el.find('#achievement_standard').closest('.row')

    if value then $row.removeClass('gone') else $row.addClass('gone')


  onSubmit: (e) =>
    e.preventDefault()
    $form = @$el.find('form')
    formArray = $form.serializeArray()

    model = {}
    _.each formArray, (obj) ->
      value = obj.value
      if (value == "true" or value == "false")
        value = if value == 'true' then true else false

      model[obj.name] = value

    @collection.add model

  onRun: ->
    results = @collection.achievement()

    $results = @$el.find('.results')
    $results.html ''
    @collection.each (d) ->
      result = d.achievement()
      $results.append "<div>Result: #{result.result} | Status: #{result.status} | Include: #{ result.include}</div>"



    $results.append "<div>Result: #{results.result} | Category: #{results.category}</div>"
