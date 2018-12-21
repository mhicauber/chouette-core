module OperationsHelper
  def operation_status(status, verbose: false, default_status: nil, i18n_prefix: nil)
    status = status.status if status.respond_to?(:status)
    status ||= default_status
    return unless status
    i18n_prefix ||= "operation_support.statuses"
    status = status.to_s.downcase
    out = if %w[new running pending].include? status
      content_tag :span, '', class: "fa fa-clock-o"
    else
      cls = ''
      cls = 'success' if status == 'successful'
      cls = 'success' if status == 'ok'
      cls = 'warning' if status == 'warning'
      cls = 'warning' if status == 'successful_with_warnings'
      cls = 'info' if status == 'canceled'
      cls = 'danger' if %w[failed aborted  error].include? status

      content_tag :span, '', class: "fa fa-circle text-#{cls}"
    end
    if verbose
      out += content_tag :span do
        txt = "#{i18n_prefix}.#{status}".t(fallback: "")
      end
    end
    out
  end
end
