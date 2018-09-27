class ComplianceCheckSetMailer < ApplicationMailer

  def finished ccset_id, user_id
    @ccset = ComplianceCheckSet.find(ccset_id)
    @user      = User.find(user_id)
    mail to: @user.email, subject: t('mailers.compliance_check_set_mailer.finished.subject')
  end
end
