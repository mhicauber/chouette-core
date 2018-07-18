$(document).on "table:updated", ->
  for menu in $('.table .dropdown-menu')
    $menu = $(menu)
    $menu.css display: "block", visibility: "hidden"
    left = $menu.parents(".t2e-item")[0].offsetLeft - $menu.parents(".t2e-item-list")[0].offsetLeft - menu.clientWidth
    $menu.toggleClass 'reversed', left > 0
    $menu.css display: "", visibility: ""
