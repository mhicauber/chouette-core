class ExportObserver < NotifiableOperationObserver
  observe Export::Gtfs, Export::Netex, Export::NetexFull

  def mailer_name(model)
    'ExportMailer'.freeze
  end
end
