import { combineReducers } from 'redux'
import vehicleJourneys from './vehicleJourneys'
import returnVehicleJourneys from './returnVehicleJourneys'
import pagination from './pagination'
import modal from './modal'
import status from './status'
import filters from './filters'
import editMode from './editMode'
import selectionMode from './selectionMode'
import selection from './selection'
import stopPointsList from './stopPointsList'
import missions from './missions'
import custom_fields from './custom_fields'

const vehicleJourneysApp = combineReducers({
  vehicleJourneys,
  returnVehicleJourneys,
  pagination,
  modal,
  status,
  filters,
  editMode,
  stopPointsList,
  returnStopPointsList: stopPointsList,
  missions,
  custom_fields,
  selectionMode,
  selection
})

export default vehicleJourneysApp
