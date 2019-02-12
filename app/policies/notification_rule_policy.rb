class NotificationRulePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def show?
    super && workbench_match?
  end

  def create?
    user.has_permission?('notification_rules.create') && workbench_match?
  end

  def destroy?
    user.has_permission?('notification_rules.destroy') && workbench_match?
  end

  def update?
    user.has_permission?('notification_rules.update') && workbench_match?
  end

  def workbench_match?
    user.workbench_ids.include? record.workbench_id
  end
end
