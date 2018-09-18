class MergeObserver < ActiveRecord::Observer

  def after_update(merge)
    return unless email_sendable_for?(merge)
    @merge = merge
    @user = User.find_by_name(@merge.creator)
    MailerJob.perform_later("MergeMailer", "finished", [@merge.id, @user.id])
  end

  private

  def enabled?
    return true unless Rails.configuration.respond_to?(:enable_merge_observer)
    !!Rails.configuration.enable_merge_observer
  end

  def email_sendable_for?(merge)
    enabled? && ['successful','failed'].include?(merge.status)
  end
end
