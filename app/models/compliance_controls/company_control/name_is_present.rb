module CompanyControl
  class NameIsPresent < InternalControl::Base
    required_features :core_controls

    only_with_custom_field Chouette::Company, :public_name

    def self.default_code; "3-Company-1" end

    def self.object_path compliance_check, company
      line_referential_company_path(company.line_referential, company)
    end

    def self.collection(lines_scope, compliance_check)
      compliance_check.referential.companies_in_lines(lines_scope)
    end

    def self.lines_for compliance_check, model
      compliance_check.referential.lines.where(company_id: model.id)
    end

    def self.compliance_test compliance_check, company
      company.custom_fields[:public_name]&.display_value.present?
    end
  end
end
