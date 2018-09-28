try_new_ellipsis_size = (container, placeholder, multiplier, originalText, direction, length, max, min, currentHeight, guard)->
  guard += 1
  placeholder.text originalText.slice(0,length) + " …"
  currentHeight = placeholder.height()
  if currentHeight > max
    newDirection = -1
  else
    newDirection = 1
  if newDirection != direction
    multiplier = multiplier/2
  direction = newDirection
  length += multiplier*direction*length
  if multiplier * originalText.length <= 1 || guard > 100
    length -= 1 if direction == 1
    container.text(originalText.slice(0,length) + " …")
    placeholder.remove()
  else
    requestAnimationFrame ->
      try_new_ellipsis_size(container, placeholder, multiplier, originalText, direction, length, max, min, currentHeight, guard)

$.fn.extend
  ellipsis: ->
    originalText = this.attr "data-originalText"
    originalText ?= this.text()
    this.attr "data-originalText", originalText
    this.text originalText
    placeholder = this.clone().addClass('placeholder').insertAfter(this)
    placeholder.text originalText
    unless placeholder.height() > placeholder.parent().height()
      this.text originalText
      placeholder.remove()
      return this
    length = originalText.length
    max = this.parent().height()
    min = this.parent().height() * 0.9
    currentHeight = placeholder.height()
    multiplier = 1/2
    direction = 1
    guard = 1
    this.data "ellipsisTimeout", null
    try_new_ellipsis_size(this, placeholder, multiplier, originalText, direction, length, max, min, currentHeight, guard)
