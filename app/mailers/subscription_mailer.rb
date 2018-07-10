class SubscriptionMailer < ApplicationMailer
  def self.enabled?
    !!Rails.configuration.enable_subscriptions_notifications
  end
  
  def created user_id
    @user = User.find(user_id)
    mail to: Rails.configuration.subscriptions_notifications_recipients, subject: t('mailers.user_mailer.created.subject')
  end
end
