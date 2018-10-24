class UserObserver < ActiveRecord::Observer

  def after_create(user)
    return unless enabled? && user.confirmed_at.nil?
    MailerJob.perform_later("UserMailer", "created", ['support@enroute.paris', 'chouette-marcom@af83.com'])
  end

  private

  def enabled?
    return true unless Rails.configuration.respond_to?(:enable_subscriptions_notifications)
    !!Rails.configuration.enable_subscriptions_notifications
  end
end
