class OrganisationPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def invite_user?
    organisation_match? && user.has_permission?('users.create')
  end


  def organisation_match?
    record.id == user.organisation_id
  end
end
