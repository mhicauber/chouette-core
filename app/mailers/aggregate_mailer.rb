class AggregateMailer < ApplicationMailer

  def finished aggregate_id, user_id
    @aggregate = Aggregate.find(aggregate_id)
    @user = User.find(user_id)
    mail to: @user.email, subject: t('mailers.aggregate_mailer.finished.subject')
  end
end
