class UserPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def destroy?
    organisation_match? && user.has_permission?('users.destroy') && record != user
  end

  def create?
    user.has_permission?('users.create')
  end

  def update?
    not_self? && organisation_match? && user.has_permission?('users.update')
  end

  def edit?
    update?
  end

  def block?
    not_self? && update? && !record.blocked?
  end

  def unblock?
    not_self? && update? && record.blocked?
  end

  def reinvite?
    organisation_match? && create? && record.state == :invited
  end

  def invite?
    create?
  end

  alias_method :new_invitation?, :invite?

  def reset_password?
    organisation_match? && update? && record.state == :confirmed
  end

  def organisation_match?
    record.organisation_id == user.organisation_id
  end

  def not_self?
    record != user
  end
end
