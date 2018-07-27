import '../../helpers/polyfills'

import clone from '../../helpers/clone'
import RoutesMap from '../../helpers/routes_map'

let routes = clone(window, "routes", true)
routes = JSON.parse(decodeURIComponent(routes))

new RoutesMap('routes_map').prepare().then(function(map){
  map.addRoutes(routes)
  map.addRoutesLabels()
  map.fitZoom()
})
