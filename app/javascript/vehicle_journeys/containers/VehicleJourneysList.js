import actions from '../actions'
import { connect } from 'react-redux'
import VehicleJourneys from '../components/VehicleJourneys'

const mapStateToProps = (state) => {
  return {
    editMode: state.editMode,
    vehicleJourneys: state.vehicleJourneys,
    status: state.status,
    filters: state.filters,
    stopPointsList: state.stopPointsList
  }
}

const mapDispatchToProps = (dispatch) => {
  return {
    onLoadFirstPage: (filters) =>{
      dispatch(actions.fetchingApi())
      actions.fetchVehicleJourneys(dispatch, undefined, undefined, filters.queryString)
    },
    onUpdateTime: (e, subIndex, index, timeUnit, isDeparture, isArrivalsToggled) => {
      dispatch(actions.updateTime(e.target.value, subIndex, index, timeUnit, isDeparture, isArrivalsToggled))
    },
    onSelectVehicleJourney: (index) => {
      dispatch(actions.selectVehicleJourney(index))
    }
  }
}

const VehicleJourneysList = connect(mapStateToProps, mapDispatchToProps)(VehicleJourneys)

export default VehicleJourneysList