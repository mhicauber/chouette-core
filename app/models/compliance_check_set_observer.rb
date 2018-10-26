class ComplianceCheckSetObserver < ActiveRecord::Observer

  def after_update(ccset)
    return unless email_sendable_for?(ccset)
    ccset = ccset
    MailerJob.perform_later("ComplianceCheckSetMailer", "finished", [ccset.id, ccset.metadata.creator_id])
  end

  private

  def enabled?
    return true unless Rails.configuration.respond_to?(:enable_subscriptions_notifications)
    !!Rails.configuration.enable_subscriptions_notifications
  end

  def email_sendable_for?(ccset)
    enabled? && ComplianceCheckSet.finished_statuses.include?(ccset.status)
  end
end
