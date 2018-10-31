class ImportObserver < ActiveRecord::Observer
  observe Import::Workbench

  def before_save(import)
    @@previous_import_statuses ||= {}
    @@previous_import_statuses[import.id] = import.status_was
  end

  def after_commit(import)
    return unless email_sendable_for?(import)

    user = User.find_by(name: import.creator)
    MailerJob.perform_later('ImportMailer', 'finished', [import.id, user.id]) if user
  end

  private

  def email_sendable_for?(import)
    previous_status = @@previous_import_statuses.delete import.id
    return false if import.class.finished_statuses.include?(previous_status)

    import.finished?
  end
end
