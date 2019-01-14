class PublicationApisController < ChouetteController
  include PolicyChecker

  defaults :resource_class => PublicationApi
  belongs_to :workgroup

  def index
    index! do |format|
      format.html {
        @publication_apis = decorate_publication_apis(@publication_apis)
      }
    end
  end

  private
  
  def resource
    super.decorate(context: { workgroup: parent })
  end

  def collection
    scope = end_of_association_chain
    @publication_apis = scope.paginate(page: params[:page])
  end

  def decorate_publication_apis publication_apis
    PublicationApiDecorator.decorate(
      publication_apis,
      context: {
        workgroup: parent
      }
    )
  end

  def publication_api_params
    publication_api_params = params.require(:publication_api)
    permitted_keys = [:name, :slug]
    publication_api_params.permit(permitted_keys)
  end
end
