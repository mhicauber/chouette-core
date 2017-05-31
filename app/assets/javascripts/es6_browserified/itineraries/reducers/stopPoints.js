var _ = require('lodash')
var addInput = require('../form_helper')

const stopPoint = (state = {}, action, length) => {
  switch (action.type) {
    case 'ADD_STOP':
      return {
        text: '',
        index: length,
        edit: true,
        for_boarding: 'normal',
        for_alighting: 'normal',
        olMap: {
          isOpened: false,
          json: {}
        }
      }
    default:
      return state
  }
}

const stopPoints = (state = [], action) => {
  switch (action.type) {
    case 'ADD_STOP':
      return [
        ...state,
        stopPoint(undefined, action, state.length)
      ]
    case 'MOVE_STOP_UP':
      return [
        ...state.slice(0, action.index - 1),
        state[action.index],
        state[action.index - 1],
        ...state.slice(action.index + 1)
      ]
    case 'MOVE_STOP_DOWN':
      return [
        ...state.slice(0, action.index),
        state[action.index + 1],
        state[action.index],
        ...state.slice(action.index + 2)
      ]
    case 'DELETE_STOP':
      return [
        ...state.slice(0, action.index),
        ...state.slice(action.index + 1).map((stopPoint)=>{
          stopPoint.index--
          return stopPoint
        })
      ]
    case 'UPDATE_INPUT_VALUE':
      return state.map( (t, i) => {
        if (i === action.index) {
          return _.assign(
            {},
            t,
            {
              stoppoint_id: "",
              text: action.text.text,
              stoparea_id: action.text.stoparea_id,
              user_objectid: action.text.user_objectid,
              latitude: action.text.latitude,
              longitude: action.text.longitude,
              name: action.text.name,
              short_name: action.text.short_name,
              area_type: action.text.area_type,
              city_name: action.text.city_name,
              comment: action.text.comment,
              registration_number: action.text.registration_number
            }
          )
        } else {
          return t
        }
      })
    case 'UPDATE_SELECT_VALUE':
      return state.map( (t, i) => {
        if (i === action.index) {
          let stopState = _.assign({}, t)
          stopState[action.select_id] = action.select_value
          return stopState
        } else {
          return t
        }
      })
    case 'TOGGLE_EDIT':
      return state.map((t, i) => {
        if (i === action.index){
          return _.assign({}, t, {edit: !t.edit})
        } else {
          return t
        }
      })
    case 'TOGGLE_MAP':
      return state.map( (t, i) => {
        if (i === action.index){
          let val = !t.olMap.isOpened
          let jsonData = val ? _.assign({}, t, {olMap: undefined}) : {}
          let stateMap = _.assign({}, t.olMap, {isOpened: val, json: jsonData})
          return _.assign({}, t, {olMap: stateMap})
        }else {
          let emptyMap = _.assign({}, t.olMap, {isOpened: false, json : {}})
          return _.assign({}, t, {olMap: emptyMap})
        }
      })
    case 'SELECT_MARKER':
      return state.map((t, i) => {
        if (i === action.index){
          let stateMap = _.assign({}, t.olMap, {json: action.data})
          return _.assign({}, t, {olMap: stateMap})
        } else {
          return t
        }
      })
    case 'UNSELECT_MARKER':
      return state.map((t, i) => {
        if (i === action.index){
          let stateMap = _.assign({}, t.olMap, {json: {}})
          return _.assign({}, t, {olMap: stateMap})
        } else {
          return t
        }
      })
    case 'CLOSE_MAP':
      return state.map( (t, i) => {
        let emptyMap = _.assign({}, t.olMap, {isOpened: false, json: {}})
        return _.assign({}, t, {olMap: emptyMap})
      })
    default:
      return state
  }
}

module.exports = stopPoints
