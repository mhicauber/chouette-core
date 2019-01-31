import React from 'react'
import PropTypes from 'prop-types'

import actions from '../../actions'

export default function SelectVehicleJourneys({onToggleTimesSelection, vehicleJourneys, disabled, selectionMode}) {
  return (
    <li className='st_action'>
      <button
        type='button'
        disabled={ disabled }
        className={ selectionMode ? 'active' : '' }
        onClick={e => {
          e.preventDefault()
          onToggleTimesSelection()
        }}
      >
        <span className='fa fa-object-group'></span>
      </button>
    </li>
  )
}

SelectVehicleJourneys.propTypes = {
  onDeleteVehicleJourneys: PropTypes.func.isRequired,
  vehicleJourneys: PropTypes.array.isRequired,
  disabled: PropTypes.bool.isRequired
}
