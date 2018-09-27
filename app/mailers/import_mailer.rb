class ImportMailer < ApplicationMailer

  def finished import_id, user_id
    @import = Import::Workbench.find(import_id)
    @user      = User.find(user_id)
    mail to: @user.email, subject: t('mailers.import_mailer.finished.subject')
  end
end
