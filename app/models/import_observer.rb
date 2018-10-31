class ImportObserver < ActiveRecord::Observer
  observe Import::Workbench

  def after_commit(import)
    return unless email_sendable_for?(import)

    user = User.find_by(name: import.creator)
    MailerJob.perform_later('ImportMailer', 'finished', [import.id, user.id]) if user
  end

  private

  def email_sendable_for?(import)
    import.finished?
  end
end
