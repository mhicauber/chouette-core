class ComplianceCheckSetObserver < ActiveRecord::Observer
  def after_update(ccset)
    return unless email_sendable_for?(ccset)

    ccset = ccset
    MailerJob.perform_later("ComplianceCheckSetMailer", "finished", [ccset.id, ccset.metadata.creator_id])
  end

  private

  def email_sendable_for?(ccset)
    return false unless ccset.context == 'manual'
    
    ComplianceCheckSet.finished_statuses.include?(ccset.status) && ccset.metadata.creator_id.present?
  end
end
