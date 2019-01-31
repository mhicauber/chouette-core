selection = (state = {}, action ) ->
  if action.type == 'TOGGLE_SELECTION'
    if !state.started
      return _.assign {}, state, { start: { x: action.x, y: action.y }, started: true}
    else
      if !state.ended
        end = { x: action.x, y: action.y }
        { topLeft, bottomRight } = computeCorners(state.start, end)
        return _.assign {}, state, { end, ended: true, topLeft, bottomRight}
      else
        return _.assign {}, state, { start: { x: action.x, y: action.y }, end: null, ended: false}
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
