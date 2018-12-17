class RouteWayCostWorker
  include Sidekiq::Worker
  extend Concerns::FailingSupport

  def perform(referential_id, route_id, retry_if_empty=true)
    Referential.find(referential_id).switch
    route = Chouette::Route.find_by id: route_id
    unless route.present?
      Rails.logger.warn "RouteWayCost called on missing route ##{route_id} in #{referential_id}".red
      return
    end

    route.calculate_costs retry_if_empty
  end
end
