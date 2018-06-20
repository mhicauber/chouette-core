class MergeReferentialsSelector
  constructor: (container_selector)->
    @container = $(container_selector)
    @searchInput = @container.find('.search')
    @searchInput.on 'keyup', =>
      @searchKeyUp()
    @loader = @container.find('.loader')
    @results = @container.find('.source-referentials')
    @selected = @container.find('.target')
    @loader.hide()
    @initSortables()
    @performSearch()
    @clearGroup = @container.find('.clear-group')
    @clearGroup.toggle(@searchInput.val().length > 0)
    @clearBt = @clearGroup.find('a')
    @formInput = $('input[name*=referential_ids]')
    @clearBt.click =>
      @clear()
    @searchInput.on 'keyup keypress', (e)=>
      keyCode = e.keyCode || e.which
      if keyCode == 13
        e.preventDefault()
        clearTimeout(@searchCoolDown) if @searchCoolDown
        @performSearch()
        false

  selectedIds: ->
    ids = []
    for item in @selected.find("li")
      ids.push $(item).data().id
    ids

  initSortables: ->
    @container.find(".source-referentials li").draggable
      connectToSortable: ".target"
      placeholder: "placeholder"
      revert: "invalid"
      cancel: ".disabled"
      helper: (event)=>
        target = event.target
        li = $(target).clone()
        li.width target.clientWidth
        li.height target.clientHeight
        li.css zIndex: 100
        li.find('a').click (e)=>
          e.preventDefault()
          @results.find("li[data-id=#{li.data().id}]").removeClass('disabled')
          li.remove()
          false
        li
    .disableSelection()
    @container.find(".target").sortable
      axis: "y"
      receive: (event, ui)=>
        ui.item.addClass "disabled"
      update: (event, ui)=>
        @formInput.val @selectedIds()
    .disableSelection()

  searchKeyUp: ->
    clearTimeout(@searchCoolDown) if @searchCoolDown
    @clearGroup.toggle(@searchInput.val().length > 0)
    @searchCoolDown = setTimeout =>
      @performSearch()
    , 500

  clear: ->
    @searchInput.val ''
    @clearGroup.hide()
    @performSearch()

  performSearch: ->
    search = @searchInput.val()
    unless @url
      @url = @searchInput.data().searchurl
    @loader.show()
    @searchInput.attr 'readonly', true
    fetch("#{@url}?q=#{search}", {
      credentials: 'same-origin'
    }).then (response) =>
      response.json()
    .then (json) =>
      @results.html ''
      _selected = @selectedIds()
      json.forEach (ref) =>
        li = $("<li data-id='#{ref.id}'>#{ref.name}<a href='#' class='pull-right delete'><span class='fa fa-times'></a></li>")
        li.appendTo @results
        li.addClass('disabled') unless _selected.indexOf(ref.id) < 0

      @searchInput.attr 'readonly', false
      @loader.hide()
      @initSortables()


export default MergeReferentialsSelector
