$ ->
  $submodeSelect = $('.js-transport-submode-select')
  if $submodeSelect.length > 0
    updateSubmodeOptions = (mode) ->
      submodeOptions = $submodeSelect.data("transport-submodes")[mode]
      $submodeSelect.find('option').remove()
      if submodeOptions
        for option in submodeOptions
          $submodeSelect.append "<option value=#{option.value} #{ 'selected' if option.value is $submodeSelect.data("selected") }>#{option.label}</option>"
        $submodeSelect.parents('.form-group').show()
      else
        $submodeSelect.parents('.form-group').hide()

    $transportModeSelect = $('.js-transport-mode-select')

    updateSubmodeOptions($transportModeSelect.val())

    $transportModeSelect.change ->
      updateSubmodeOptions($(this).val())
