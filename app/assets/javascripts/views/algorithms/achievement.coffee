class Visio.Views.AlgorithmView extends Backbone.View

  template: HAML['algorithms/achievement']

  events:
    'change #is_performance': 'onChangePerformance'
    'submit form': 'onSubmit'
    'click .run': 'onRun'
    'change .algorithms input': 'onAlgorithmChange'

  initialize: (options) ->
    @collection.on 'add', @addOne
    @algorithm = options.algorithm
    @render()

  render: ->
    @$el.html @template({ algorithm: @algorithm })
    @addAll()
    @

  addAll: ->
    @collection.each @addOne, @

  addOne: (model) =>

    view = new Visio.Views.IndicatorDatumShowView( model: model )
    @$el.find('.indicators').append view.render().el

  onChangePerformance: (e) ->
    value = if $(e.currentTarget).val() == 'true' then true else false

    $row = @$el.find(".impact-only").closest('.row')

    if value then $row.addClass('gone') else $row.removeClass('gone')


  onSubmit: (e) =>
    e.preventDefault()
    $form = @$el.find('form')
    formArray = $form.serializeArray()

    model = {}
    _.each formArray, (obj) ->
      value = obj.value
      if (value == "true" or value == "false")
        value = if value == 'true' then true else false
      else
        value = +value

      model[obj.name] = value

    @collection.add model

  onRun: ->
    results = @collection[@algorithm]()

    $results = @$el.find('.results')
    $results.html "<h5>#{@algorithm}</h5>"
    @collection.each (d) =>
      result = d[@algorithm]()
      $results.append "<div>#{JSON.stringify(result, null, 2)}</div>"



    $results.append "<div>#{JSON.stringify(results, null, 2)}</div>"

  onAlgorithmChange: (e) ->
    $target = $(e.currentTarget)
    @algorithm = $target.val()
