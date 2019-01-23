class ComplianceCheckBlock < ApplicationModel
  include ComplianceBlockSupport

  belongs_to :compliance_check_set

  has_many :compliance_checks, dependent: :nullify

  def collection(compliance_check)
    collection_type = compliance_check.control_class.collection_type(compliance_check)
    send("#{collection_type}_collection", compliance_check)
  end

  def lines_collection(compliance_check)
    scope = compliance_check.referential.lines

    if transport_mode?
      if transport_submode
        scope = scope.where(transport_submode: transport_submode)
      elsif transport_mode
        scope = scope.where(transport_mode: transport_mode)
      end
    end

    if stop_areas_in_countries?
      matching_routes = routes_collection(compliance_check)
      ids = matching_routes.select(:line_id).uniq.to_sql
      scope = scope.where("lines.id IN (#{ids})")
    end
    scope
  end

  def routes_collection(compliance_check)
    scope = compliance_check.referential.routes

    if transport_mode?
      scope = scope.where(line_id: lines_collection(compliance_check).pluck(:id))
    end

    if stop_areas_in_countries?
      matching = scope.joins(:stop_areas)
      matching = matching.where('lower(country_code) = ?', country.downcase)
      matching = matching.group('routes.id')
      matching = matching.having('COUNT(*) >= ?', min_stop_areas_in_country)
      scope = scope.where(id: matching.pluck(:id))
    end

    scope
  end

  def journey_patterns_collection(compliance_check)
    compliance_check.referential.journey_patterns.where(route_id: routes_collection(compliance_check).pluck(:id))
  end

  def vehicle_journeys_collection(compliance_check)
    compliance_check.referential.vehicle_journeys.joins(:route).where(route_id: routes_collection(compliance_check).pluck(:id))
  end

  def companies_collection(compliance_check)
    compliance_check.referential.companies.where(id: lines_collection(compliance_check).pluck(:company_id).uniq)
  end

  def stop_areas_collection(compliance_check)
    ids = routes_collection(compliance_check).joins(:stop_points).select('stop_area_id').uniq.pluck(:stop_area_id)
    compliance_check.referential.stop_areas.where(id: ids)
  end

  alias_method :associated_stop_areas_collection, :stop_areas_collection
end
