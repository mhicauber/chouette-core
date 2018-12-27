class NotifiableOperationObserver < ActiveRecord::Observer
  def mailer_name(model)
    "#{model.class.name}Mailer"
  end

  def after_update(model)
    return unless email_sendable_for?(model)

    model.notify_relevant_users mailer_name(model), 'finished' do |recipients|
      [model.id, recipients, model.status]
    end
  end

  private

  def email_sendable_for?(model)
    model.class.finished_statuses.include?(model.status) && model.notified_recipients_at.blank? && model.has_notification_recipients?
  end
end
