# Budget Summary
class Visio.Figures.BmySummary extends Visio.Figures.Bmy

  initialize: ->
    super
    @filters.get('group_by').set 'hidden', true

    @groupBy = "#{Visio.Utils.parameterByPlural(Visio.manager.get('aggregation_type')).singular}_id"
