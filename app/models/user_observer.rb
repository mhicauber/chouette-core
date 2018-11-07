class UserObserver < ActiveRecord::Observer
  def after_create(user)
    return unless enabled? && user.confirmed_at.nil?

    MailerJob.perform_later('UserMailer', 'created', [user.id, Rails.configuration.subscriptions_notifications_recipients])
  end

  private

  def enabled?
    return false unless Rails.configuration.respond_to?(:subscriptions_notifications_recipients)

    return true unless Rails.configuration.respond_to?(:enable_subscriptions_notifications)

    !!Rails.configuration.enable_subscriptions_notifications
  end
end
