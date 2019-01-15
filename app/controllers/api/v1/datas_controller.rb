class Api::V1::DatasController < ActionController::Base
  before_action :load_publication_api

  def infos
    render layout: 'api'
  end

  protected

  def load_publication_api
    @publication_api = PublicationApi.find_by! slug: params[:slug]
  end
end
