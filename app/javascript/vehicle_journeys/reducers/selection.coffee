import ClipboardHelper from '../../helpers/clipboard'

selection_paste_content = (rawContent, state) ->
  {content, error} = ClipboardHelper.paste rawContent, state
  if error
    return _.assign {}, state, { copyModal: { visible: true, mode: 'paste', error: error } }
  else
    return _.assign {}, state, { copyModal: { visible: false } }

selection = (state = {}, action ) ->
  if action.type == 'COPY_CLIPBOARD'
    return _.assign {}, state, { copyModal: { visible: true, mode: 'copy', content: ClipboardHelper.copy(state.clipboard) } }

  if action.type == 'COPY_MODAL_TO_PASTE_MODE'
    return _.assign {}, state, { copyModal: { visible: true, mode: 'paste', content: '' } }

  if action.type == 'COPY_MODAL_TO_COPY_MODE'
    return _.assign {}, state, { copyModal: { visible: true, mode: 'copy', content: ClipboardHelper.copy(state.clipboard) } }

  if action.type == 'CLOSE_COPY_MODAL'
    return _.assign {}, state, { copyModal: { visible: false } }

  if action.type == 'UPDATE_CONTENT_TO_PASTE'
    new_state = _.assign {}, state, { rawContent: action.content }
    if new_state.copyModal.visible && new_state.copyModal.mode == 'paste'
      {error} = ClipboardHelper.paste action.content, state
      new_state = _.assign {}, new_state, { copyModal: { visible: true, mode: 'paste', content: action.content, error: error } }

    return new_state

  if action.type == 'PASTE_CONTENT'
    return selection_paste_content(state.rawContent, state)

  if action.type == 'TOGGLE_SELECTION'
    if action.clickDirection == 'down'
      lastDown = state.lastDown
      if state.lastDown && state.lastDown.x == action.x && state.lastDown.y == action.y
        lastDown = {}

      if !state.started
        lastDown = { x: action.x, y: action.y}
        return _.assign {}, state, { start: lastDown, started: true, lastDown, bottomRight: lastDown, topLeft: lastDown, width: 1, height: 1}
      else if state.ended && !action.shiftKey
        lastDown = { x: action.x, y: action.y}
        return _.assign {}, state, { start: { x: action.x, y: action.y }, end: null, ended: false, lastDown, bottomRight: lastDown, topLeft: lastDown, width: 1, height: 1}

      return _.assign {}, state, {lastDown}
    else
      if state.started
        return state if state.lastDown && state.lastDown.x == action.x &&  state.lastDown.y == action.y

        if !state.ended || action.shiftKey
          end = { x: action.x, y: action.y }
          {topLeft, bottomRight, width, height} = computeCorners(state.start, end)

          clipboard = {}
          for vehicleJourney, x in action.vehicleJourneys
            if x >= topLeft.x && x <= bottomRight.x
              for VehicleJourneyAtStop, y in vehicleJourney.vehicle_journey_at_stops
                if y >= topLeft.y && y <= bottomRight.y
                  clipboard[y] ||= []
                  clipboard[y].push VehicleJourneyAtStop.arrival_time

          return _.assign {}, state, { end, topLeft, width, height, bottomRight, ended: true, clipboard }

  else if action.type == 'HOVER_CELL'
    lastSeen = { x: action.x, y: action.y }
    if state.started && (!state.ended || action.shiftKey)
      end = lastSeen
      {topLeft, bottomRight, width, height} = computeCorners(state.start, end)
      return _.assign {}, state, { end, topLeft, width, height, bottomRight, ended: false}
    return _.assign {}, state, { lastSeen }

  else if action.type == 'KEY_UP'
    if action.event.key == 'Shift'
      if state.started && !state.ended
        return _.assign {}, state, { ended: true }

  else if action.type == 'KEY_DOWN'
    if action.event.key == 'Shift'
      if state.started
        end = state.lastSeen
        {topLeft, bottomRight, width, height} = computeCorners(state.start, end)
        return _.assign {}, state, { end, topLeft, bottomRight, width, height, ended: false}
    else
      if action.event.key == "c" && (action.event.metaKey || action.event.ctrlKey)
        if state.started && state.ended && !state.copyModal.visible
          content = ClipboardHelper.copy state.clipboard
          return _.assign {}, state, { copyModal: { visible: true, mode: 'copy', content } }
      else if action.event.key == "Enter" && (action.event.metaKey || action.event.ctrlKey) && state.copyModal.visible
        if state.copyModal.mode == 'copy'
          return _.assign {}, state, { copyModal: { visible: true, mode: 'paste', content: '' } }
        else
          return selection_paste_content(state.rawContent, state)


  else if action.type == 'VISIBILITY_CHANGE'
    if state.copyModal.visible && state.copyModal.mode == 'copy'
      return _.assign {}, state, { copyModal: { visible: true, mode: 'paste', content: '' } }

  return state

computeCorners = (start, end)->
    min_x = Math.min(start.x, end.x)
    max_x = Math.max(start.x, end.x)
    min_y = Math.min(start.y, end.y)
    max_y = Math.max(start.y, end.y)
    topLeft = {x: min_x, y: min_y}
    bottomRight = {x: max_x, y: max_y}
    width = max_x - min_x + 1
    height = max_y - min_y + 1

    {topLeft, bottomRight, width, height}

export default selection
