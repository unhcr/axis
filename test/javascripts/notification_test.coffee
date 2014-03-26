module 'Notification'

test 'render', ->
  title = 'ben'
  description = 'rudolph'
  notification = new Visio.Views.Error
    title: title
    description: description

  strictEqual notification.$el.find('.notification-title').text().trim(), title
  strictEqual notification.$el.find('.notification-description').text().trim(), description
  ok notification.$el.hasClass 'notification'
  ok notification.$el.hasClass 'error'

  notification.close()

test 'timed close', ->
  title = 'lisa'
  description = 'rudolph'
  notification = new Visio.Views.Notification
    title: title
    description: description
    timeout: 0

  ok not $('body').find('.notification').length

