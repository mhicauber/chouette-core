class PublicationApiKeyPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def create?
    user.has_permission?('publication_api_keys.create')
  end

  def update?
    user.has_permission?('publication_api_keys.update')
  end

  def destroy?
    user.has_permission?('publication_api_keys.destroy')
  end
end
