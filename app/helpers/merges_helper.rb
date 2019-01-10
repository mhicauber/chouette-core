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

  def merge_metadatas(merge)
    {
      Merge.tmf(:referentials) => merge.referentials.map{ |r| link_to(r.name, referential_path(r)) }.join(', ').html_safe,
      Merge.tmf(:status) => operation_status(merge.status, verbose: true, i18n_prefix: "merges.statuses"),
      Merge.tmf(:new) => merge.new ? link_to(merge.new.name, referential_path(merge.new)) : '-',
      Merge.tmf(:operator) => merge.creator,
      Merge.tmf(:created_at) => merge.created_at ? l(merge.created_at) : '-',
      Merge.tmf(:ended_at) => merge.ended_at ? l(merge.ended_at) : '-',
      Merge.tmf(:notification_target) => I18n.t("operation_support.notification_targets.#{merge.notification_target || 'none'}")
    }
  end
end
