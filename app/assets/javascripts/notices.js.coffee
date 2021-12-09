root = exports ? this

# Display growl notices with bootstrap-growl.js (http://bootstrap-growl.remabledesigns.com/)
class Notices
  constructor: (options) ->
    @options =
      ele: 'body'
      position:
        from: 'top'
        align: 'right'
    @options = $.extend @options, options

  danger: (message) -> @message message, 'danger'
  info: (message) -> @message message, 'info'
  success: (message) -> @message message, 'success'
  warning: (message) -> @message message, 'warning'

  message: (message, type) ->
    $.growl message, $.extend @options, {type: type}

root.Notices = Notices
