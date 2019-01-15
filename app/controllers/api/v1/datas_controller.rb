class Api::V1::DatasController < ActionController::Base
  before_action :load_publication_api

  def infos
    render layout: 'api'
  end

  def download_full
    source = @publication_api.publication_api_sources.find_by! key: params[:key]
    send_file source.file.path
  end

  protected

  def load_publication_api
    @publication_api = PublicationApi.find_by! slug: params[:slug]
  end
end
