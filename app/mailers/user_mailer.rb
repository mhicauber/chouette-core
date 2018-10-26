class UserMailer < ApplicationMailer

  def created user_id, email
    @user      = User.find(user_id)
    mail to: email, subject: t('mailers.user_mailer.created.subject')
  end
end
