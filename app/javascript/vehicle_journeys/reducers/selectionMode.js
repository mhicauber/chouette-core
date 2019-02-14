export default function selectionMode(state = {}, action ) {
  switch (action.type) {
    case "TOGGLE_SELECTION_MODE":
      return !state
    default:
      return state
  }
}
