class ApiKeyPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def destroy?
    organisation_match? && user.has_permission?('api_keys.destroy')
  end

  def create?
    user.has_permission?('api_keys.create')
  end

  def update?
    organisation_match? && user.has_permission?('api_keys.update')
  end

  def edit?
    update?
  end

  def organisation_match?
    record.workbench.organisation_id == user.organisation_id
  end
end
