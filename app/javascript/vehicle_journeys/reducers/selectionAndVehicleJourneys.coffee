import _ from 'lodash'
import ClipboardHelper from '../../helpers/clipboard'

getSchedules = (selection, vehicleJourneys) ->
  schedules = {}
  for vehicleJourney, x in vehicleJourneys
    if x >= selection.topLeft.x && x <= selection.bottomRight.x
      for VehicleJourneyAtStop, y in vehicleJourney.vehicle_journey_at_stops
        if y >= selection.topLeft.y && y <= selection.bottomRight.y
          schedules[y] ||= []
          schedules[y].push { arrival_time: VehicleJourneyAtStop.arrival_time, departure_time: VehicleJourneyAtStop.departure_time }

  schedules

selectionAndVehicleJourneys = (state, action) ->
  selection = state.selection
  vehicleJourneys = state.vehicleJourneys
  if action.type == 'PASTE_CONTENT' || action.type == 'KEY_DOWN' && action.event.key == "Enter" && (action.event.metaKey || action.event.ctrlKey) && selection.copyModal.visible && selection.copyModal.mode == 'paste'
    {content, error} = ClipboardHelper.paste(selection.rawContent, selection, state.filters.toggleArrivals)
    if error
      selection = _.assign {}, selection, { copyModal: { visible: true, mode: 'paste', error: error } }
    else
      selection = _.assign {}, selection, { copyModal: { visible: false } }
      vehicleJourneys = vehicleJourneys.map (vj, x) ->
        if x >= selection.topLeft.x && x <= selection.bottomRight.x
          vjasArray = vj.vehicle_journey_at_stops.map (vjas, y) ->
            if y >= selection.topLeft.y && y <= selection.bottomRight.y
              departure_time = content[y - selection.topLeft.y][x - selection.topLeft.x].departure_time
              if state.filters.toggleArrivals
                arrival_time = content[y - selection.topLeft.y][x - selection.topLeft.x].arrival_time
                return _.assign({}, vjas, {departure_time, arrival_time})
              else
                return _.assign({}, vjas, {departure_time})

            return vjas
          return _.assign({}, vj, { vehicle_journey_at_stops: vjasArray })
        return vj

    return _.assign {}, state, { vehicleJourneys, selection }

  if action.type == 'UPDATE_CONTENT_TO_PASTE'
    new_selection = _.assign {}, selection, { rawContent: action.content }
    if new_selection.copyModal.visible && new_selection.copyModal.mode == 'paste'
      {error} = ClipboardHelper.paste action.content, selection, state.filters.toggleArrivals
      new_selection = _.assign {}, new_selection, { copyModal: { visible: true, mode: 'paste', content: action.content, error: error } }

    return _.assign {}, state, { selection: new_selection }

  if action.type == 'KEY_DOWN' && action.event.key == "Enter" && (action.event.metaKey || action.event.ctrlKey) && selection.copyModal.visible && selection.copyModal.mode == 'copy'
    selection = _.assign {}, selection, { copyModal: { visible: true, mode: 'paste', content: '' } }
    return _.assign {}, state, { selection }

  if action.type == 'COPY_CLIPBOARD' || action.type == 'COPY_MODAL_TO_COPY_MODE' || action.type == 'KEY_DOWN' && action.event.key == "c" && (action.event.metaKey || action.event.ctrlKey) && selection.started && selection.ended && !selection.copyModal.visible
    schedules = getSchedules(selection, vehicleJourneys)
    selection = _.assign({}, selection, { copyModal: { visible: true, mode: 'copy', content: ClipboardHelper.copy(schedules, state.filters.toggleArrivals) } })
    return _.assign {}, state, { selection }

  if action.type == 'PASTE_CLIPBOARD' || action.type == 'KEY_DOWN' && action.event.key == "v" && (action.event.metaKey || action.event.ctrlKey) && selection.started && selection.ended && !selection.copyModal.visible
    selection = _.assign {}, selection, { copyModal: { visible: true, mode: 'paste', content: '' } }
    return _.assign {}, state, { selection }

  state

export default selectionAndVehicleJourneys
