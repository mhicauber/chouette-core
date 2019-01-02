class ComplianceCheckBlock < ApplicationModel
  include ComplianceBlockSupport

  belongs_to :compliance_check_set

  has_many :compliance_checks, dependent: :nullify

  def lines_scope(compliance_check)
    scope = compliance_check.referential.lines

    if transport_mode?
      if transport_submode
        scope = scope.where(transport_submode: transport_submode)
      elsif transport_mode
        scope = scope.where(transport_mode: transport_mode)
      end
    end

    if stop_areas_in_countries?
      matching_routes = compliance_check.referential.routes_in_lines(scope)
      matching_routes = matching_routes.joins(:stop_areas)
      matching_routes = matching_routes.where('lower(country_code) = ?', country.downcase)
      matching_routes = matching_routes.group('routes.id')
      matching_routes = matching_routes.having('COUNT(*) >= ?', min_stop_areas_in_country)
      ids = matching_routes.select(:line_id).uniq.to_sql
      scope = scope.where("lines.id IN (#{ids})")
    end
    scope
  end
end
