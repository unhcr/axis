# My == Multiple year
class Visio.SelectedData.My extends Visio.SelectedData.Base

  year: ->
    @get('d').year


  idField: ->
    parameter = Visio.Utils.parameterByName Visio.manager.get('aggregation_type')

    "#{parameter.singular}_ids"

  formattedIds: ->
    ids = Visio.manager.formattedIds()

    idField = @idField()

    #ids[idField] = @collection.pluck('id')

    ids

