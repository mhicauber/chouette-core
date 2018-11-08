class ComplianceCheckSetMailer < ApplicationMailer

  def finished(ccset_id, recipients, status=nil)
    @ccset = ComplianceCheckSet.find(ccset_id)
    @status = status || @ccset.status
    mail to: recipients, subject: t('mailers.compliance_check_set_mailer.finished.subject')
  end
end
