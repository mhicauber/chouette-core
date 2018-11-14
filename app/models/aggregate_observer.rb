class AggregateObserver < ActiveRecord::Observer

  def after_update(aggregate)
    return unless email_sendable_for?(aggregate)

    aggregate.notify_relevant_users 'AggregateMailer', 'finished' do |recipients|
      [aggregate.id, recipients, aggregate.status]
    end
  end

  private

  def email_sendable_for?(aggregate)
    Aggregate.finished_statuses.include?(aggregate.status) && aggregate.notified_recipients_at.blank?
  end
end
