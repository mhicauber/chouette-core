class ExportObserver < ActiveRecord::Observer
  observe Export::Gtfs, Export::Netex

  def after_update(export)
    return unless email_sendable_for?(export)
    user = User.find_by_name(export.creator)
    MailerJob.perform_later("ExportMailer", "finished", [export.id, user.id])
  end

  private

  def enabled?
    return true unless Rails.configuration.respond_to?(:enable_subscriptions_notifications)
    !!Rails.configuration.enable_subscriptions_notifications
  end

  def email_sendable_for?(export)
    enabled? && export.finished?
  end
end
