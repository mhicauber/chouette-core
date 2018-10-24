class AggregateObserver < ActiveRecord::Observer

  def after_update(aggregate)
    return unless email_sendable_for?(aggregate)
    aggregate = aggregate
    user = User.find_by_name(aggregate.creator)
    MailerJob.perform_later("MergeMailer", "finished", [aggregate.id, user.id])
  end

  private

  def enabled?
    return true unless Rails.configuration.respond_to?(:enable_subscriptions_notifications)
    !!Rails.configuration.enable_subscriptions_notifications
  end

  def email_sendable_for?(aggregate)
    enabled? && Aggregate.finished_statuses.include?(aggregate.status)
  end
end
