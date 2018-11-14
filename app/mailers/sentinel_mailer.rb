class SentinelMailer < ApplicationMailer
  def notify_incoming_holes(workbench, referential)
    @referential = referential
    mail(
      bcc: workbench.sentinel_notifications_recipients,
      subject: t('mailers.sentinel_mailer.finished.subject')
    )
  end
end
