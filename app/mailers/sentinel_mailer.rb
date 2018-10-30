class SentinelMailer < ApplicationMailer
  def notify_incoming_holes(workbench, holes)
    @holes = holes
    @workbench = workbench
    mail(
      to: workbench.sentinel_notifications_recipients,
      subject: t('mailers.sentinel_mailer.incoming_holes.subject', workbench_name: workbench.name)
    )
  end
end
