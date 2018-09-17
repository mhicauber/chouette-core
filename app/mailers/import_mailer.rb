class ImportMailer < ApplicationMailer

  def created import_id, user_id
    @import = Import::Base.find(import_id)
    @user      = User.find(user_id)
    mail to: @user.email, subject: t('mailers.import_mailer.created.subject')
  end
end
