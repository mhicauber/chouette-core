class ExportObserver < NotifiableOperationObserver
  observe Export::Gtfs, Export::Netex

  def mailer_name(model)
    'ExportMailer'.freeze
  end
end
