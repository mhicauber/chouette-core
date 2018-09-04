class ApiKeysController < ChouetteController
  defaults resource_class: ApiKey

  belongs_to :workbench
  include PolicyChecker

  before_action :load_workbench

  def index
    index! do
      @api_keys = ApiKeyDecorator.decorate(
        collection,
        context: { workbench: @workbench }
      )
    end
  end

  def create
    create! do |success, _failure|
      success.html do
        redirect_to workbench_api_keys_path(@workbench)
      end
    end
  end

  def update
    update! do |success, _failure|
      success.html do
        redirect_to workbench_api_keys_path(@workbench)
      end
    end
  end

  private

  def api_key_params
    params.require(:api_key).permit(:name)
  end

  def load_workbench
    @workbench = parent
  end

  def begin_of_association_chain
    current_organisation
  end

end
