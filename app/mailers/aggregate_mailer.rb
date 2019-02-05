class AggregateMailer < ApplicationMailer
  def finished(aggregate_id, recipients, status=nil)
    @aggregate = Aggregate.find(aggregate_id)
    @status = status || @aggregate.status
    mail bcc: recipients, subject: t("mailers.#{@aggregate.class.name.underscore}_mailer.finished.subject")
  end
end
