class UserObserver < ActiveRecord::Observer

  def after_create(user)
    return unless email_sendable_for?(user)
    MailerJob.perform_later("UserMailer", "created", ['support@enroute.paris', 'chouette-marcom@af83.com'])
  end

  private

  def enabled?
    return true unless Rails.configuration.respond_to?(:enable_user_observer)
    !!Rails.configuration.enable_user_observer
  end

  def email_sendable_for?(user)
    enabled? && user.organisation.has_feature?(:new_user_mail)
  end
end
