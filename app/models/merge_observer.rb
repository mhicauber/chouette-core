class MergeObserver < ActiveRecord::Observer
  def after_update(merge)
    return unless email_sendable_for?(merge)

    merge.notify_relevant_users 'MergeMailer', 'finished' do |recipients|
      [merge.id, recipients, merge.status]
    end
  end

  private

  def email_sendable_for?(merge)
    Merge.finished_statuses.include?(merge.status) && merge.notified_recipients_at.blank?
  end
end
