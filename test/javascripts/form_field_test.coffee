module 'FormField',
  setup: ->
    @formField = new Visio.Models.FormField
      name: 'operations'
      human: 'Operations'
      formElement: 'checkboxes'
      type: 'collection'
      collection: -> new Visio.Collections.Operation()

test 'setSelected', ->
  @formField.setSelected [1, 2]

  ok @formField.selected 1
  ok @formField.selected 2

  @formField.setSelected [12]

  ok @formField.selected 12

test 'selected', ->
  @formField.setSelected [1, 2]

  ok @formField.selected 1

  @formField.selected 1, false
  ok not @formField.selected 1

  @formField.selected 3, true
  ok @formField.selected 3
  ok @formField.selected 2
