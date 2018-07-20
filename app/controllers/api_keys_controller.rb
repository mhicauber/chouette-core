class ApiKeysController < ChouetteController
  belongs_to :workbench
  include PolicyChecker

  private

  def api_key_params
    params.require(:api_key).permit(:name)
  end
end
