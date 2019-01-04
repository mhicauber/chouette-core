class PublicationSetupPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def create?
    user.has_permission?('publication_setups.create')
  end

  def update?
    user.has_permission?('publication_setups.update')
  end

  def destroy?
    user.has_permission?('publication_setups.destroy')
  end
end
