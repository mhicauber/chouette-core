class AggregatePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def create?
    user.has_permission?('aggregates.create')
  end

  def rollback?
    !record.current? && record.successful? && organisation_match? && user.has_permission?('aggregates.rollback')
  end

  def organisation_id
    record.workgroup.owner_id
  end
end
