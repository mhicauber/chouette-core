export default class StopAreaFormHelper {
  constructor() {
    this.handleKindChange('commercial', false)
    this.handleKindChange('non_commercial', true)
  }

  handleKindChange(kind, bool) {
    document.getElementById(`stop_area_kind_${kind}`).addEventListener('change', () => {
      document.getElementById('stop_area_parent_id').disabled = bool
    })
  }
}