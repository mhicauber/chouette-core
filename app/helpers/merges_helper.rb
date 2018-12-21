module MergesHelper
  def merge_status(status, current_icon=false)
    cls = ''
    cls = 'success' if status == 'successful'
    cls = 'success' if status == 'ok'
    cls = 'warning' if status == 'warning'
    cls = 'info' if status == 'canceled'
    cls = 'danger' if %w[failed aborted  error].include? status

    content_tag :div, '' do
      concat content_tag :span, '', class: "fa fa-circle text-#{cls}"
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
