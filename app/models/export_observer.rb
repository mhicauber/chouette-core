class ExportObserver < ActiveRecord::Observer
  observe Export::Gtfs, Export::Netex

  def after_update(export)
    return unless email_sendable_for?(export)

    export.notify_relevant_users 'ExportMailer', 'finished' do |recipients|
      [export.id, recipients, export.status]
    end
  end

  private

  def email_sendable_for?(export)
    export.finished? && export.changes.include?('status')
  end
end
