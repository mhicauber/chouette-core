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
    @clearGroup.hide()
    @clearBt = @clearGroup.find('a')
    @formInput = $('input[name*=referential_ids]')
    @clearBt.click =>
      @clear()

  selectedIds: ->
    ids = []
    for item in @selected.find("li")
      ids.push $(item).data().id
    ids

  initSortables: ->
    @container.find( ".source-referentials, .target" ).sortable
      connectWith: ".connectedSortable"
      update: =>
        @formInput.val @selectedIds()
    .disableSelection()

  searchKeyUp: ->
    console.log "searchKeyUp"
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
      for ref in json
        if _selected.indexOf(ref.id) < 0
          li = $("<li data-id='#{ref.id}'>#{ref.name}</li>")
          li.appendTo @results
      @searchInput.attr 'readonly', false
      @loader.hide()
      @initSortables()


export default MergeReferentialsSelector
