class ExportObserver < ActiveRecord::Observer
  observe Export::Gtfs, Export::Netex

  def after_create(export)
    return unless enabled?
    user = User.find_by_name(export.creator)
    MailerJob.perform_later("ExportMailer", "created", [export.id, user.id])
  end

  private

  def enabled?
    return true unless Rails.configuration.respond_to?(:enable_export_observer)
    !!Rails.configuration.enable_import_observer
  end
end
