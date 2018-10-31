class ExportObserver < ActiveRecord::Observer
  observe Export::Gtfs, Export::Netex

  def before_save(export)
    @@previous_export_statuses ||= {}
    @@previous_export_statuses[export.id] = export.status_was
  end

  def after_commit(export)
    return unless email_sendable_for?(export)

    user = User.find_by(name: export.creator)
    MailerJob.perform_later('ExportMailer', 'finished', [export.id, user.id])
  end

  private

  def email_sendable_for?(export)
    previous_status = @@previous_export_statuses.delete export.id
    return false if export.class.finished_statuses.include?(previous_status)

    export.finished?
  end
end
