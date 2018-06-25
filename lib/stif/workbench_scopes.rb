module Stif
  class WorkbenchScopes < ::WorkbenchScopes::All

    def lines_scope(initial_scope)
      ids = parse_functional_scope
      ids ? initial_scope.where(objectid: ids) : initial_scope
    end

    protected

    def parse_functional_scope
      return false unless @workbench.organisation.sso_attributes
      begin
        JSON.parse @workbench.organisation.sso_attributes['functional_scope']
      rescue Exception => e
        Rails.logger.error "WorkbenchScopes : #{e}"
      end
    end
  end
end
