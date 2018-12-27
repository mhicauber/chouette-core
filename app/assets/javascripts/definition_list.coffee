$ ->
  $('.definition-list').each (i, el)->
    list = $(el)
    head = $(el).find(".dl-head")

    if head.hasClass('togglable')
      head.click (e) ->
        head.toggleClass 'toggled'
        $(el).find(".dl-body .togglable").toggleClass('visible')
