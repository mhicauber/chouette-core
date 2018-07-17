class ApiKeysController < ChouetteController
  defaults resource_class: ApiKey

  belongs_to :workbench
  include PolicyChecker

  def create
    @api_key = @workbench.api_keys.new(api_key_params.merge(workbench: current_workbench))
    create! do |format|
      format.html {
        redirect_to dashboard_path
      }
    end
  end

  def update
    update! do |format|
      format.html {
        redirect_to dashboard_path
      }
    end
  end

  def destroy
    destroy! do |format|
      format.html {
        redirect_to dashboard_path
      }
    end
  end

  private

  def api_key_params
    params.require(:api_key).permit(:name)
  end
end
