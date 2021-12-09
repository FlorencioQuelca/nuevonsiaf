root = exports ? this

class Utils
  # Set the focus to the next element
  @nextFieldFocus: ($e) ->
    $formGroup = $e.closest('.form-group')
    $elem = $formGroup.next('.form-group').find('input, select, button, textarea')
    $elem.focus()

  # Convert single quotes to hyphen
  @singleQuotesToHyphen: (string) ->
    value = string.toString().trim()
    value.replace(/\'/g, '-')

root.Utils = Utils
