class PublicationApiPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def create?
    user.has_permission?('publication_apis.create')
  end

  def update?
    user.has_permission?('publication_apis.update')
  end

  def destroy?
    user.has_permission?('publication_apis.destroy')
  end
end
