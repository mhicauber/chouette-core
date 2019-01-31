import actions from '../actions'
import { connect } from 'react-redux'
import VehicleJourneys from '../components/VehicleJourneys'

const mapStateToProps = (state) => {
  return {
    editMode: state.editMode,
    selectionMode: state.selectionMode,
    selection: state.selection,
    vehicleJourneys: state.vehicleJourneys,
    returnVehicleJourneys: state.returnVehicleJourneys,
    status: state.status,
    filters: state.filters,
    stopPointsList: state.stopPointsList,
    returnStopPointsList: state.returnStopPointsList,
    extraHeaders: window.extra_headers,
    customFields: window.custom_fields,
  }
}

const mapDispatchToProps = (dispatch) => {
  return {
    onLoadFirstPage: (filters, routeUrl) =>{
      dispatch(actions.fetchingApi())
      actions.fetchVehicleJourneys(dispatch, undefined, undefined, filters.queryString, routeUrl)
    },
    onUpdateTime: (e, subIndex, index, timeUnit, isDeparture, isArrivalsToggled, enforceConsistency=false) => {
      dispatch(actions.updateTime(e.target.value, subIndex, index, timeUnit, isDeparture, isArrivalsToggled, enforceConsistency))
    },
    onSelectVehicleJourney: (index) => {
      dispatch(actions.selectVehicleJourney(index))
    },
    onOpenInfoModal: (vj) =>{
      dispatch(actions.openInfoModal(vj))
    },
    onSelectCell: (x, y, mouseEvent, vehicleJourneys)=>{
      dispatch(actions.toggleSelection(x, y, mouseEvent, vehicleJourneys))
    },
    onHoverCell: (x, y)=>{
      dispatch(actions.onHoverCell(x, y))
    }
  }
}

const VehicleJourneysList = connect(mapStateToProps, mapDispatchToProps)(VehicleJourneys)

export default VehicleJourneysList
