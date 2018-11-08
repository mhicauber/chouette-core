class MergeMailer < ApplicationMailer
  def finished(merge_id, recipients, status = nil)
    @merge = Merge.find(merge_id)
    @status = status || @merge.status
    mail bcc: recipients, subject: t('mailers.merge_mailer.finished.subject')
  end
end
