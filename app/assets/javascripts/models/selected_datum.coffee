class Visio.Models.SelectedDatum extends Backbone.Model

  year: ->
    Visio.manager.year()

  reportedType: ->
    Visio.manager.get 'reported_type'

  formattedIds: ->

    ids = Visio.manager.formattedIds()

    idField = @idField()

    ids[idField] = [@id()]

    ids

  idField: ->
    "#{@get('d').name.singular}_ids"

  id: ->
    @get('d').id

  summaryParameters: ->
    ids = @formattedIds()

    # Don't use output ids for summarization
    delete ids["#{Visio.Parameters.OUTPUTS.singular}_ids"]
    delete ids["#{Visio.Parameters.INDICATORS.singular}_ids"]

    params =
      year: @year()
      reported_type: @reportedType()
      ids: ids

    params
