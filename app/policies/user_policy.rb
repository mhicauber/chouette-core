class UserPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def destroy?
    organisation_match? && user.has_permission?('users.destroy')
  end

  def create?
    user.has_permission?('users.create')
  end

  def update?
    organisation_match? && user.has_permission?('users.update')
  end

  def edit?
    update?
  end

  def block?
    update? && !record.blocked? && record != user
  end

  def unblock?
    update? && record.blocked? && record != user
  end

  def reinvite?
    organisation_match? && create? && record.state == :invited
  end

  def reset_password?
    organisation_match? && update? && record.state == :confirmed
  end

  def organisation_match?
    record.organisation_id == user.organisation_id
  end
end
