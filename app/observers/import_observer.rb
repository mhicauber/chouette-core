class ImportObserver < NotifiableOperationObserver
  observe Import::Workbench

  def mailer_name(model)
    'ImportMailer'.freeze
  end
end
