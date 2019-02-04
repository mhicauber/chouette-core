import actions from '../../actions'
import { connect } from 'react-redux'
import PasteButtonComponent from '../../components/tools/PasteButton'

const mapStateToProps = (state, ownProps) => {
  return {
    disabled: ownProps.disabled,
    selectionMode: state.selectionMode
  }
}

const mapDispatchToProps = (dispatch) => {
  return {
    onClick: () =>{
      dispatch(actions.pasteFromClipboard())
    },
  }
}

const PasteButton = connect(mapStateToProps, mapDispatchToProps)(PasteButtonComponent)

export default PasteButton
