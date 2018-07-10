class UserObserver < ActiveRecord::Observer
  def after_create(user)
    return unless enabled?

    MailerJob.perform_later("UserMailer", "created", user.id)
  end

  private

  def enabled?
    !!Rails.configuration.enable_subscriptions_notifications
  end
end
