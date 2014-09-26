# My == Multiple year
class Visio.SelectedData.My extends Visio.SelectedData.Base

  year: ->
    @get('d').year


  idField: ->
    parameter = Visio.Utils.parameterByName Visio.manager.get('aggregation_type')

    "#{parameter.singular}_ids"

  name: ->
    @get('d').name

  formattedIds: ->
    ids = Visio.manager.formattedIds()

    idField = @idField()

    ids["#{@get('d').id_type.singular}_ids"] = [@get('d').id] unless @get('d').summary

    console.log ids
    ids
