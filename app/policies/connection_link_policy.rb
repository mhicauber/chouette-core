class ConnectionLinkPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def create?
    !referential_read_only? && organisation_match? && user.has_permission?('connection_links.create')
  end

  def destroy?
    !referential_read_only? && organisation_match? && user.has_permission?('connection_links.destroy')
  end

  def update?
    !referential_read_only? && organisation_match? && user.has_permission?('connection_links.update')
  end
end
