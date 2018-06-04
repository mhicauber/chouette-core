class WorkgroupPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def create?
    false
  end

  def destroy?
    false
  end

  def update?
    record.owner == user.organisation
  end
end
