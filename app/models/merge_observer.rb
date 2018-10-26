class MergeObserver < ActiveRecord::Observer

  def after_update(merge)
    return unless email_sendable_for?(merge)
    merge = merge
    user = User.find_by_name(merge.creator)
    MailerJob.perform_later("MergeMailer", "finished", [merge.id, user.id])
  end

  private

  def enabled?
    return true unless Rails.configuration.respond_to?(:enable_subscriptions_notifications)
    !!Rails.configuration.enable_subscriptions_notifications
  end

  def email_sendable_for?(merge)
    enabled? && Merge.finished_statuses.include?(merge.status)
  end
end
