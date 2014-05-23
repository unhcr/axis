class Visio.Models.StrategyCMSManager extends Visio.Models.Manager

  initialize: (options) ->
    super options

    console.warn 'is_personal not set. Defaulting to global' unless options.is_personal?
    options.is_personal or= false

    @set 'is_personal', options.is_personal
