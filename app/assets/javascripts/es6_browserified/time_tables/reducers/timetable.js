const _ = require('lodash')
var actions = require('../actions')
let newState = {}
let newPeriods = []
let newDates = []
let newCM = []

const timetable = (state = {}, action) => {
  switch (action.type) {
    case 'RECEIVE_TIME_TABLES':
      let fetchedState = _.assign({}, state, {
        current_month: action.json.current_month,
        current_periode_range: action.json.current_periode_range,
        periode_range: action.json.periode_range,
        time_table_periods: action.json.time_table_periods,
        time_table_dates: _.sortBy(action.json.time_table_dates, ['date'])
      })
      return _.assign({}, fetchedState, {current_month: actions.updateSynthesis(fetchedState, actions.strToArrayDayTypes(action.json.day_types))})
    case 'RECEIVE_MONTH':
      newState = _.assign({}, state, {
        current_month: action.json.days
      })
      return _.assign({}, newState, {current_month: actions.updateSynthesis(newState, actions.strToArrayDayTypes(action.json.day_types))})
    case 'GO_TO_PREVIOUS_PAGE':
    case 'GO_TO_NEXT_PAGE':
      let nextPage = action.nextPage ? 1 : -1
      let newPage = action.pagination.periode_range[action.pagination.periode_range.indexOf(action.pagination.currentPage) + nextPage]
      $('#ConfirmModal').modal('hide')
      actions.fetchTimeTables(action.dispatch, newPage)
      return _.assign({}, state, {current_periode_range: newPage})
    case 'CHANGE_PAGE':
      $('#ConfirmModal').modal('hide')
      actions.fetchTimeTables(action.dispatch, action.page)
      return _.assign({}, state, {current_periode_range: action.page})
    case 'DELETE_PERIOD':
      newPeriods = state.time_table_periods.map((period, i) =>{
        if(i == action.index){
          period.deleted = true
        }
        return period
      })
      let deletedPeriod = state.time_table_periods[action.index]
      newDates = actions.updateExcludedDates(deletedPeriod.period_start, deletedPeriod.period_end, state.time_table_dates)
      newState = _.assign({}, state, {time_table_periods : newPeriods, time_table_dates: newDates})
      return _.assign({}, newState, { current_month: actions.updateSynthesis(newState, action.dayTypes)})
    case 'ADD_INCLUDED_DATE':
      newDates = state.time_table_dates.concat({date: action.date, in_out: true})
      newCM = state.current_month.map((d, i) => {
        if (i == action.index) d.include_date = true
        return d
      })
      return _.assign({}, state, {current_month: newCM, time_table_dates: newDates})
    case 'REMOVE_INCLUDED_DATE':
      newDates = _.reject(state.time_table_dates, ['date', action.date])
      newCM = state.current_month.map((d, i) => {
        if (i == action.index) d.include_date = false
        return d
      })
      return _.assign({}, state, {current_month: newCM, time_table_dates: newDates})
    case 'ADD_EXCLUDED_DATE':
      newDates = state.time_table_dates.concat({date: action.date, in_out: false})
      newCM = state.current_month.map((d, i) => {
        if (i == action.index) d.excluded_date = true
        return d
      })
      return _.assign({}, state, {current_month: newCM, time_table_dates: newDates})
    case 'REMOVE_EXCLUDED_DATE':
      newDates = _.reject(state.time_table_dates, ['date', action.date])
      newCM = state.current_month.map((d, i) => {
        if (i == action.index) d.excluded_date = false
        return d
      })
      return _.assign({}, state, {current_month: newCM, time_table_dates: newDates})
    case 'UPDATE_DAY_TYPES':
      // We get the week days of the activated day types to reject the out_dates that that are out of newDayTypes
      let weekDays = _.reduce(action.dayTypes, (array, dt, i) => {
        if (dt) array.push(i)
        return array
      }, [])

      newDates =  _.reject(state.time_table_dates, (d) => {
        let weekDay = new Date(d.date).getDay()

        if (d.in_out) {
          return actions.isInPeriod(state.time_table_periods, d.date) && weekDays.includes(weekDay)
        } else {
          return !weekDays.includes(weekDay)
        }
      })
      return _.assign({}, state, {time_table_dates: newDates})
    case 'UPDATE_CURRENT_MONTH_FROM_DAYTYPES':
      return _.assign({}, state, {current_month: actions.updateSynthesis(state, action.dayTypes)})
    case 'VALIDATE_PERIOD_FORM':
      if (action.error != '') return state

      let period_start = actions.formatDate(action.modalProps.begin)
      let period_end = actions.formatDate(action.modalProps.end)

      let newPeriods = JSON.parse(JSON.stringify(action.timeTablePeriods))

      if (action.modalProps.index !== false){
        updatePeriod = state.time_table_periods[action.modalProps.index]
        updatePeriod.period_start = period_start
        updatePeriod.period_end = period_end
        newDates = actions.updateExcludedDates(updatePeriod.period_start, updatePeriod.period_end, state.time_table_dates)
      }else{
        let newPeriod = {
          period_start: period_start,
          period_end: period_end
        }
        newPeriods.push(newPeriod)
      }
      
      newDates = newDates || state.time_table_dates
      newState =_.assign({}, state, {time_table_periods: newPeriods, time_table_dates: newDates})
      return _.assign({}, newState, {current_month: actions.updateSynthesis(newState, action.metas.day_types)})
    default:
      return state
  }
}

module.exports = timetable
