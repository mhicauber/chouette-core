class NotificationRulePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end
  def create?
    user.has_permission?('notification_rules.create')
  end

  def destroy?
    user.has_permission?('notification_rules.destroy')
  end

  def update?
    user.has_permission?('notification_rules.update')
  end
end
