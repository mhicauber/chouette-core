class RouteWayCostWorker
  include Sidekiq::Worker

  def perform(referential_id, route_id)
    Referential.find(referential_id).switch
    route = Chouette::Route.find_by id: route_id
    unless route.present?
      Rails.logger.warn "RouteWayCost called on missing route ##{route_id} in #{referential_id}".red
      return
    end

    route.calculate_costs
  end
end
