class ComplianceCheckSetObserver < ActiveRecord::Observer
  def after_update(ccset)
    return unless email_sendable_for?(ccset)

    ccset.notify_relevant_users 'ComplianceCheckSetMailer', 'finished' do |recipients|
      [ccset.id, recipients, ccset.status]
    end
  end

  private

  def email_sendable_for?(ccset)
    return false unless ccset.context == 'manual'

    ComplianceCheckSet.finished_statuses.include?(ccset.status) && ccset.notified_recipients_at.blank?
  end
end
