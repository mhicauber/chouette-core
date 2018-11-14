class ImportObserver < ActiveRecord::Observer
  observe Import::Workbench

  def after_update(import)
    return unless email_sendable_for?(import)

    import.notify_relevant_users 'ImportMailer', 'finished' do |recipients|
      [import.id, recipients, import.status]
    end
  end

  private

  def email_sendable_for?(import)
    import.finished? && import.notified_recipients_at.blank?
  end
end
