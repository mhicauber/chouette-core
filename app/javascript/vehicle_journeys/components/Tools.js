import React, { Component } from 'react'
import PropTypes from 'prop-types'
import actions from '../actions'
import AddVehicleJourney from '../containers/tools/AddVehicleJourney'
import DeleteVehicleJourneys from '../containers/tools/DeleteVehicleJourneys'
import ShiftVehicleJourney from '../containers/tools/ShiftVehicleJourney'
import DuplicateVehicleJourney from '../containers/tools/DuplicateVehicleJourney'
import EditVehicleJourney from '../containers/tools/EditVehicleJourney'
import NotesEditVehicleJourney from '../containers/tools/NotesEditVehicleJourney'
import TimetablesEditVehicleJourney from '../containers/tools/TimetablesEditVehicleJourney'
import PurchaseWindowsEditVehicleJourney from '../containers/tools/PurchaseWindowsEditVehicleJourney'
import ConstraintExclusionEditVehicleJourney from '../containers/tools/ConstraintExclusionEditVehicleJourney'


export default class Tools extends Component {
  constructor(props) {
    super(props)
    this.hasPolicy = this.hasPolicy.bind(this)
  }

  hasPolicy(key) {
    // Check if the user has the policy to disable or not the action
    return this.props.filters.policy[`vehicle_journeys.${key}`]
  }

  hasFeature(key) {
    // Check if the organisation has the given feature
    return this.props.filters.features[key]
  }

  render() {
    let { vehicleJourneys, onCancelSelection, editMode } = this.props
    return (
      <div className='select_toolbox'>
        <ul>
          <AddVehicleJourney disabled={!this.hasPolicy("create") || !editMode} />
          <DuplicateVehicleJourney disabled={!this.hasPolicy("create") || !this.hasPolicy("update") || !editMode}/>
          <ShiftVehicleJourney disabled={!this.hasPolicy("update") || !editMode}/>
          <EditVehicleJourney disabled={false}/>

          <TimetablesEditVehicleJourney disabled={false}/>
          { this.hasFeature('purchase_windows') &&
            <PurchaseWindowsEditVehicleJourney disabled={false}/>
          }
          <ConstraintExclusionEditVehicleJourney disabled={false}/>
          <NotesEditVehicleJourney disabled={false}/>
          <DeleteVehicleJourneys disabled={!this.hasPolicy("destroy") || !editMode}/>
        </ul>

        <span className='info-msg'>{I18n.t('vehicle_journeys.vehicle_journeys_matrix.selected_journeys', {count: actions.getSelected(vehicleJourneys).length})}</span>
        <button className='btn btn-xs btn-link pull-right' onClick={onCancelSelection}>{I18n.t('vehicle_journeys.vehicle_journeys_matrix.cancel_selection')}</button>
      </div>
    )
  }
}

Tools.propTypes = {
  vehicleJourneys : PropTypes.array.isRequired,
  onCancelSelection: PropTypes.func.isRequired,
  filters: PropTypes.object.isRequired
}
