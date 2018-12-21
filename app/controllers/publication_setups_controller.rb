class PublicationSetupsController < ChouetteController
  include PolicyChecker

  defaults :resource_class => PublicationSetup
  belongs_to :workgroup

  respond_to :html

  def index
    index! do |format|
      format.html {
        @publication_setups = decorate_publication_setups(@publication_setups)
      }
    end
  end

  def publication_setup_params
    publication_setup_params = params.require(:publication_setup)
    permitted_keys = [:name, :export_type, :export_options, :enabled, :workgroup_id]
    publication_setup_params[:workgroup_id] = parent.id
    export_class = publication_setup_params[:export_type] && publication_setup_params[:export_type].safe_constantize
    if export_class
      permitted_keys << { export_options: export_class.options.keys }
    end
    permitted_destinations_attributes = [:id, :name, :type, :_destroy, :secret_file, :publication_setup_id]
    permitted_destinations_attributes += Destination.descendants.map{ |t| t.options.keys }.uniq
    permitted_keys << { destinations_attributes: permitted_destinations_attributes }
    publication_setup_params.permit(permitted_keys)
  end

  def resource
    super.decorate(context: { workgroup: parent })
  end

  def collection
    scope = end_of_association_chain
    @publication_setups = scope.paginate(:page => params[:page])
  end

  def decorate_publication_setups publication_setups
    PublicationSetupDecorator.decorate(
      publication_setups,
      context: {
        workgroup: parent
      }
    )
  end
end
