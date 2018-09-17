class ImportObserver < ActiveRecord::Observer
  observe Import::Gtfs, Import::Netex

  def after_create(import)
    return unless enabled?
    user = User.find_by_name(import.parent.creator)
    MailerJob.perform_later("ImportMailer", "created", [import.id, user.id])
  end

  private

  def enabled?
    return true unless Rails.configuration.respond_to?(:enable_import_observer)
    !!Rails.configuration.enable_import_observer
  end
end
