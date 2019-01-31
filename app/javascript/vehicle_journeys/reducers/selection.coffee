selection = (state = {}, action ) ->
  if action.type == 'TOGGLE_SELECTION'
    if action.mouseEvent == 'down'
      lastDown = state.lastDown
      if state.lastDown && state.lastDown.x == action.x && state.lastDown.y == action.y
        lastDown = {}

      if !state.started
        lastDown = { x: action.x, y: action.y}
        return _.assign {}, state, { start: { x: action.x, y: action.y }, started: true, lastDown}
      else if state.ended
        lastDown = { x: action.x, y: action.y}
        return _.assign {}, state, { start: { x: action.x, y: action.y }, end: null, ended: false, lastDown}

      return _.assign {}, state, {lastDown}
    else
      if state.started
        return state if state.lastDown && state.lastDown.x == action.x &&  state.lastDown.y == action.y

        if !state.ended
          end = { x: action.x, y: action.y }
          { topLeft, bottomRight } = computeCorners(state.start, end)

          return _.assign {}, state, { end, topLeft, bottomRight, ended: true }

  else if action.type == 'HOVER_CELL'
    if state.started && !state.ended
      end = { x: action.x, y: action.y }
      { topLeft, bottomRight } = computeCorners(state.start, end)
      return _.assign {}, state, { end, topLeft, bottomRight}

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
