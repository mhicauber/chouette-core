class ComplianceCheckSetPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.where(workbench_id: user.organisation.workbench_ids)
    end

  end

  def show?
    user.organisation
    super || record.workbench.workgroup.owner == user.organisation
  end
end
