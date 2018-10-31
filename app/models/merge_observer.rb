class MergeObserver < ActiveRecord::Observer

  def after_commit(merge)
    return unless email_sendable_for?(merge)

    user = User.find_by(name: merge.creator)
    MailerJob.perform_later('MergeMailer', 'finished', [merge.id, user.id]) if user
  end

  private

  def email_sendable_for?(merge)
    Merge.finished_statuses.include?(merge.status)
  end
end
