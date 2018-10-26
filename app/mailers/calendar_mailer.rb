class CalendarMailer < ApplicationMailer
  def updated calendar_id, user_id
    @calendar = Calendar.find(calendar_id)
    @user      = User.find(user_id)
    mail to: @user.email, subject: t('mailers.calendar_mailer.updated.subject')
  end

  def created calendar_id, user_id
    @calendar = Calendar.find(calendar_id)
    @user      = User.find(user_id)
    mail to: @user.email, subject: t('mailers.calendar_mailer.created.subject')
  end
end
