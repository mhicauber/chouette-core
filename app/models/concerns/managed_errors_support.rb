module ManagedErrorsSupport
  def notify_invalid_model model, message: nil, context: nil, severity: :warning
    message ||= "#{model.class.name} is not valid"
    e = Chouette::ErrorsManager::InvalidModelError.new message
    e.set_backtrace full_error_backtrace
    Chouette::ErrorsManager.invalid_model model, message: message, context: context, exception: e, severity: severity
  end

  def log_error message, context: nil, severity: :warning
    e = Chouette::ErrorsManager::ErrorLog.new message
    e.set_backtrace full_error_backtrace
    Chouette::ErrorsManager.log_error message, context: context, exception: e, severity: severity
  end

  def full_error_backtrace
    backtrace = Thread.current.backtrace
    backtrace.unshift caller[1]
    backtrace
  end
end
