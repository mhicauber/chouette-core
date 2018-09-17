class ImportObserver < ActiveRecord::Observer
  observe Import::Gtfs, Import::Netex

  def after_update(import)
    return unless email_sendable_for?(import)
    user = User.find_by_name(import.parent.creator)
    MailerJob.perform_later("ImportMailer", "finished", [import.id, user.id])
  end

  private

  def enabled?
    return true unless Rails.configuration.respond_to?(:enable_import_observer)
    !!Rails.configuration.enable_import_observer
  end

  def email_sendable_for?(import)
    enabled? && import.status != 'running'
  end
end
