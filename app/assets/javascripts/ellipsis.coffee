try_new_ellipsis_size = (container, placeholder, multiplier, originalText, direction, length, max, min, dimension, guard)->
  guard += 1
  placeholder.text originalText.slice(0,length) + "…"

  if dimension() >= max
    newDirection = -1
  else
    newDirection = 1
  if newDirection != direction
    multiplier = multiplier/2
  direction = newDirection
  length += multiplier*direction*length
  if multiplier * originalText.length <= 1 || guard > 100
    length -= 1 if direction == 1
    container.text(originalText.slice(0,length-1) + "…")
    placeholder.remove()
  else
    requestAnimationFrame ->
      try_new_ellipsis_size(container, placeholder, multiplier, originalText, direction, length, max, min, dimension, guard)

placeholderHeight = (placeholder)->
  ->
    placeholder.height()

placeholderWidth = (placeholder)->
  ->
    textNode = placeholder[0].firstChild
    range = document.createRange()
    range.selectNodeContents textNode
    rects = range.getClientRects()
    val = 0
    for rect in rects
      val = Math.max(val, rect.width)
    val

$.fn.extend
  ellipsis: ->
    originalText = this.attr "data-originalText"
    originalText ?= this.text()
    this.attr "data-originalText", originalText
    this.text originalText
    placeholder = this.clone().addClass('placeholder').insertAfter(this)
    placeholder.css
      margin: 0
      padding: 0
    placeholder.text originalText

    unless placeholder.height() > placeholder.parent().height() || placeholderWidth(placeholder)() > placeholder.parent().width()
      this.text originalText
      placeholder.remove()
      return this
    length = originalText.length

    if placeholder.height() > placeholder.parent().height()
      max = this.parent().height()
      min = this.parent().height() * 0.9
      dimension = placeholderHeight(placeholder)
    else
      max = this.parent().width()
      min = this.parent().width() * 0.9
      dimension = placeholderWidth(placeholder)

    multiplier = 1/2
    direction = 1
    guard = 1
    this.data "ellipsisTimeout", null
    try_new_ellipsis_size(this, placeholder, multiplier, originalText, direction, length, max, min, dimension, guard)
