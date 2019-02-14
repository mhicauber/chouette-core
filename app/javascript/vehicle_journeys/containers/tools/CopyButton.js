import actions from '../../actions'
import { connect } from 'react-redux'
import CopyButtonComponent from '../../components/tools/CopyButton'

const mapStateToProps = (state, ownProps) => {
  return {
    disabled: ownProps.disabled,
    selectionMode: state.selectionMode
  }
}

const mapDispatchToProps = (dispatch) => {
  return {
    onClick: () =>{
      dispatch(actions.copyClipboard())
    },
  }
}

const CopyButton = connect(mapStateToProps, mapDispatchToProps)(CopyButtonComponent)

export default CopyButton
