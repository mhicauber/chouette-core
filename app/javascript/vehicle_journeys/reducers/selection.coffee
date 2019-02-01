selection = (state = {}, action ) ->
  console.log(action)
  if action.type == 'TOGGLE_SELECTION'
    if action.clickDirection == 'down'
      lastDown = state.lastDown
      if state.lastDown && state.lastDown.x == action.x && state.lastDown.y == action.y
        lastDown = {}

      if !state.started
        lastDown = { x: action.x, y: action.y}
        return _.assign {}, state, { start: { x: action.x, y: action.y }, started: true, lastDown}
      else if state.ended && !action.shiftKey
        lastDown = { x: action.x, y: action.y}
        return _.assign {}, state, { start: { x: action.x, y: action.y }, end: null, ended: false, lastDown}

      return _.assign {}, state, {lastDown}
    else
      if state.started
        return state if state.lastDown && state.lastDown.x == action.x &&  state.lastDown.y == action.y

        if !state.ended || action.shiftKey
          end = { x: action.x, y: action.y }
          { topLeft, bottomRight } = computeCorners(state.start, end)

          clipboard = {}
          for vehicleJourney, x in action.vehicleJourneys
            if x >= topLeft.x && x <= bottomRight.x
              for VehicleJourneyAtStop, y in vehicleJourney.vehicle_journey_at_stops
                if y >= topLeft.y && y <= bottomRight.y
                  clipboard[y] ||= []
                  clipboard[y].push VehicleJourneyAtStop.arrival_time

          return _.assign {}, state, { end, topLeft, bottomRight, ended: true, clipboard }

  else if action.type == 'HOVER_CELL'
    lastSeen = { x: action.x, y: action.y }
    if state.started && (!state.ended || action.shiftKey)
      end = lastSeen
      { topLeft, bottomRight } = computeCorners(state.start, end)
      return _.assign {}, state, { end, topLeft, bottomRight, ended: false}
    return _.assign {}, state, { lastSeen }

  else if action.type == 'KEY_UP' && action.event.key == 'Shift'
    if state.started && !state.ended
      return _.assign {}, state, { ended: true }

  else if action.type == 'KEY_DOWN' && action.event.key == 'Shift'
    if state.started
      end = state.lastSeen
      { topLeft, bottomRight } = computeCorners(state.start, end)
      return _.assign {}, state, { end, topLeft, bottomRight, ended: false}

  return state

computeCorners = (start, end)->
    min_x = Math.min(start.x, end.x)
    max_x = Math.max(start.x, end.x)
    min_y = Math.min(start.y, end.y)
    max_y = Math.max(start.y, end.y)
    topLeft = {x: min_x, y: min_y}
    bottomRight = {x: max_x, y: max_y}

    {topLeft, bottomRight}

export default selection
