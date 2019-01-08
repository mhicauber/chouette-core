module MergesHelper
  def merge_status(status, current_icon=false)
    content_tag :span, '' do
      concat operation_status(status)
      concat render_current_icon if current_icon
    end
  end

  def render_current_icon
    content_tag :span, '',
      class: 'sb sb-compliance_control_set',
      style: 'margin-left:5px; font-weight: 600',
      title: I18n.t('merges.show.table.state.title')
  end
end
