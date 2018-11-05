class ImportMailer < ApplicationMailer

  def finished import_id, user_id, import_status = nil
    @import = Import::Base.find(import_id)
    @user   = User.find(user_id)
    @import_status = import_status || @import.status
    mail to: @user.email, subject: t('mailers.import_mailer.finished.subject')
  end
end
