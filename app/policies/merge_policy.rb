class MergePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def create?
    user.has_permission?('merges.create')
  end

  def rollback?
    !record.current? && record.successful? && organisation_match? && user.has_permission?('merges.rollback')
  end

  def organisation_match?
    user.organisation_id == organisation_id
  end

  def organisation_id
    record.workbench.organisation_id
  end
end
