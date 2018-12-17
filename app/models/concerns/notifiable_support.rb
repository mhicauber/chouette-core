module NotifiableSupport
  extend ActiveSupport::Concern

  included do
    extend Enumerize
    enumerize :notification_target, in: %w[none user workbench], default: :none
    belongs_to :user
  end

  module ClassMethods
    def notification_target_options
      notification_target.values.map { |k| [k && "operation_support.notification_targets.#{k}".t, k] }
    end
  end

  def notify_relevant_users(mailer, action)
    recipients = notification_recipients
    return unless recipients.present?

    mailer_params = yield(recipients)

    begin
      MailerJob.perform_later(mailer, action, mailer_params)
    rescue => e
      Chouette::ErrorsManager.handle_error e, 'Can\'t notify users'
    end

    notify_recipients!
  end

  def notified_recipients?
    notified_recipients_at.present?
  end

  def notify_recipients!
    update_column :notified_recipients_at, Time.now
  end

  def workbench_for_notifications
    workbench
  end

  def notification_recipients
    return [] unless has_notification_recipients?

    users = if notification_target.to_s == 'user'
      [user]
    else
      workbench_for_notifications.users
    end

    users.compact.map(&:email_recipient)
  end

  def has_notification_recipients?
    notification_target.present? && notification_target.to_s != 'none'
  end
end
