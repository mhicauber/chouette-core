class VehicleJourneysController < ChouetteController
  defaults :resource_class => Chouette::VehicleJourney
  before_action :check_policy, only: [:edit, :update, :destroy]
  before_action :user_permissions, only: :index
  before_action :ransack_params, only: :index

  respond_to :json, :only => :index
  respond_to :js, :only => [:select_journey_pattern, :edit, :new, :index]

  belongs_to :referential do
    belongs_to :line, :parent_class => Chouette::Line do
      belongs_to :route, :parent_class => Chouette::Route
    end
  end

  alias_method :vehicle_journeys, :collection
  alias_method :route, :parent
  alias_method :vehicle_journey, :resource

  def select_journey_pattern
    if params[:journey_pattern_id]
      selected_journey_pattern = Chouette::JourneyPattern.find( params[:journey_pattern_id])

      @vehicle_journey = vehicle_journey
      @vehicle_journey.update_journey_pattern(selected_journey_pattern)
    end
  end

  def create
    create!(:alert => t('activerecord.errors.models.vehicle_journey.invalid_times'))
  end

  def update
    update!(:alert => t('activerecord.errors.models.vehicle_journey.invalid_times'))
  end

  def index
    @stop_points_list = []
    route.stop_points.each do |sp|
      @stop_points_list << {
        :id => sp.stop_area.id,
        :route_id => sp.try(:route_id),
        :object_id => sp.try(:objectid),
        :position => sp.try(:position),
        :for_boarding => sp.try(:for_boarding),
        :for_alighting => sp.try(:for_alighting),
        :name => sp.stop_area.try(:name),
        :zip_code => sp.stop_area.try(:zip_code),
        :city_name => sp.stop_area.try(:city_name),
        :comment => sp.stop_area.try(:comment),
        :area_type => sp.stop_area.try(:area_type),
        :registration_number => sp.stop_area.try(:registration_number),
        :nearest_topic_name => sp.stop_area.try(:nearest_topic_name),
        :fare_code => sp.stop_area.try(:fare_code),
        :longitude => sp.stop_area.try(:longitude),
        :latitude => sp.stop_area.try(:latitude),
        :long_lat_type => sp.stop_area.try(:long_lat_type),
        :country_code => sp.stop_area.try(:country_code),
        :street_name => sp.stop_area.try(:street_name)
      }
    end

    index! do
      if collection.out_of_bounds?
        redirect_to params.merge(:page => 1)
      end
      build_breadcrumb :index
    end
  end

  # overwrite inherited resources to use delete instead of destroy
  # foreign keys will propagate deletion)
  def destroy_resource(object)
    object.delete
  end

  protected
  def collection
    @ppage = 20
    @q     = route.sorted_vehicle_journeys('vehicle_journeys').search params[:q]
    @vehicle_journeys = @q.result.paginate(:page => params[:page], :per_page => @ppage)
    @footnotes = route.line.footnotes.to_json
    @matrix    = resource_class.matrix(@vehicle_journeys)
    @vehicle_journeys
  end

  def adapted_params
    params.tap do |adapted_params|
      adapted_params.merge!( :route => parent)
      hour_entry = "vehicle_journey_at_stops_departure_time_gt(4i)".to_sym
      if params[:q] && params[:q][ hour_entry]
        adapted_params[:q].merge! hour_entry => (params[:q][ hour_entry].to_i - utc_offset)
      end
    end
  end
  def utc_offset
    # Ransack Time eval - utc eval
    sample = [2001,1,1,10,0]
    Time.zone.local(*sample).utc.hour - Time.utc(*sample).hour
  end

  def check_policy
    authorize resource
  end

  def user_permissions
    @perms = {}.tap do |perm|
      ['vehicle_journeys.create', 'vehicle_journeys.edit', 'vehicle_journeys.destroy'].each do |name|
        perm[name] = current_user.permissions.include?(name)
      end
    end
    @perms = @perms.to_json
  end

  private
  def ransack_params
    if params[:q]
      params[:q] = params[:q].reject{|k| params[:q][k] == 'undefined'}
      [:departure_time_gteq, :departure_time_lteq].each do |filter|
        time = params[:q]["vehicle_journey_at_stops_#{filter}"]
        params[:q]["vehicle_journey_at_stops_#{filter}"] = "2000-01-01 #{time}:00 UTC"
      end
    end
  end

  def vehicle_journey_params
    params.require(:vehicle_journey).permit( { footnote_ids: [] } , :journey_pattern_id, :number, :published_journey_name,
                                             :published_journey_identifier, :comment, :transport_mode,
                                             :mobility_restricted_suitability, :flexible_service, :status_value,
                                             :facility, :vehicle_type_identifier, :objectid, :time_table_tokens,
                                             { date: [ :hour, :minute ] }, :button, :referential_id, :line_id,
                                             :route_id, :id, { vehicle_journey_at_stops_attributes: [ :arrival_time,
                                                                                                      :id, :_destroy,
                                                                                                      :stop_point_id,
                                                                                                      :departure_time] } )
  end
end
