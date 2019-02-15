class NotificationRulePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.where(workbench_id: user.workbench_ids)
    end
  end

  def show?
    super && workbench_match?
  end

  def create?
    user.has_permission?('notification_rules.create')
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
