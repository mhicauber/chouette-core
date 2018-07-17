class Api::V1::WorkbenchController < ActionController::Base
  respond_to :json, :xml

  inherit_resources

  layout false
  before_action :authenticate

  protected

  def begin_of_association_chain
    @current_workbench
  end

  private

  def authenticate
    authenticate_with_http_basic do |code, token|
      api_key = ApiKey.find_by(token: token)
      workbench = api_key&.workbench
      @current_workbench = workbench if workbench && workbench.organisation.code == code
    end

    unless @current_workbench
      request_http_basic_authentication
    end
  end

  def switch_referential
    @current_workbench.output.switch
  end
end
