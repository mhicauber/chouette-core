class ImportMailer < ApplicationMailer

  def finished(import_id, recipients, import_status = nil)
    @import = Import::Base.find(import_id)
    @import_status = import_status || @import.status
    mail bcc: recipients, subject: t('mailers.import_mailer.finished.subject')
  end
end
