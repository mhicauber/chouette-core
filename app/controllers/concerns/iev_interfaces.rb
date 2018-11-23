module IevInterfaces
  extend ActiveSupport::Concern

  included do
    before_action only: [:index] { set_date_time_params("started_at", DateTime) }
    before_action :ransack_status_params, only: [:index]
    respond_to :html
    belongs_to :workbench
    helper_method :collection_name, :index_model
  end

  def show
    show! do
      instance_variable_set "@#{collection_name.singularize}", resource.decorate(context: {
        workbench: @workbench
      })
    end
  end

  def index
    index! do |format|
      format.html {
        if collection.out_of_bounds?
          redirect_to params.merge(:page => 1)
        end
        collection = decorate_collection(collection)
      }
    end
  end

  protected

  def begin_of_association_chain
    current_organisation
  end

  def collection
    scope = parent.send(collection_name).where(parent_id: nil)
    if index_model.name.demodulize != "Base"
      scope = scope.where(type: index_model.name)
    end
    @types = scope.select('DISTINCT(type)').map &:class

    scope = self.ransack_period_range(scope: scope, error_message:  t("#{collection_name}.filters.error_period_filter"), query: :where_started_at_in)

    @q = scope.search(params[:q])

    unless instance_variable_get "@#{collection_name}"
      coll = if sort_column && sort_direction
        @q.result(distinct: true).order(sort_column + ' ' + sort_direction).paginate(page: params[:page], per_page: 10)
      else
        @q.result(distinct: true).order(:name).paginate(page: params[:page], per_page: 10)
      end
      instance_variable_set "@#{collection_name}", decorate_collection(coll)
    end
    instance_variable_get "@#{collection_name}"
  end

  private
  def ransack_status_params
    if params[:q]
      return params[:q].delete(:status_eq_any) if params[:q][:status_eq_any].empty? || ( (resource_class.status.values & params[:q][:status_eq_any]).length >= 4 )
      params[:q][:status_eq_any].push("new", "running") if params[:q][:status_eq_any].include?("pending")
      params[:q][:status_eq_any].push("aborted", "canceled") if params[:q][:status_eq_any].include?("failed")
    end
  end

  def sort_column
    parent.imports.column_names.include?(params[:sort]) ? params[:sort] : 'created_at'
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ?  params[:direction] : 'desc'
  end
end
