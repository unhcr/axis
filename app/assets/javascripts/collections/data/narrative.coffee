class Visio.Collections.Narrative extends Visio.Collections.AmountType

  model: Visio.Models.Narrative

  name: Visio.Syncables.NARRATIVES

  url: '/narratives'

  toHtmlText: ->

    @pluck('usertxt').join('<br />').replace(/\\n/g, '<br />')
