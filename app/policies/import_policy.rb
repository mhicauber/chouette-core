class ImportPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.where(workbench_id: user.organisation.workbench_ids)
    end
  end

  def show?
    super || record.workbench.workgroup.owner == user.organisation
  end

  def create?
    user.has_permission?('imports.create')
  end

  def update?
    user.has_permission?('imports.update')
  end
end
