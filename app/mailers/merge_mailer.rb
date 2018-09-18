class MergeMailer < ApplicationMailer

  def finished merge_id, user_id
    @merge = Merge.find(merge_id)
    @user = User.find(user_id)
    mail to: @user.email, subject: t('mailers.merge_mailer.finished.subject')
  end
end
