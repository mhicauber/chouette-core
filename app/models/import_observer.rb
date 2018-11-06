class ImportObserver < ActiveRecord::Observer
  observe Import::Workbench

  def after_update(import)
    return unless email_sendable_for?(import)

    user = User.find_by(name: import.creator)
    MailerJob.perform_later('ImportMailer', 'finished', [import.id, user.id, import.status]) if user
  end

  private

  def email_sendable_for?(import)
    import.finished? && import.changes.include?('status')
  end

end
