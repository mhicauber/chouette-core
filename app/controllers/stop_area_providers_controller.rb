class StopAreaProvidersController < ChouetteController
  include ApplicationHelper

  belongs_to :stop_area_referential

  defaults :resource_class => StopAreaProvider

  def index
    index! do |format|
      format.html {
        if collection.out_of_bounds?
          redirect_to params.merge(:page => 1)
        end

        @stop_area_providers = StopAreaProviderDecorator.decorate(@stop_area_providers)
      }
    end
  end

  def show
    @stop_area_provider = resource.decorate
  end

  def collection
    scope = policy_scope(parent.stop_area_providers)

    @stop_area_providers ||= begin
      stop_area_providers = scope.order(:name)
      stop_area_providers = stop_area_providers.paginate(:page => params[:page])
      stop_area_providers
    end
  end

  def stop_area_provider_params
    fields = [
      :name,
      {stop_area_ids: []}
    ]
    params.require(:stop_area_provider).permit(fields)
  end
end
