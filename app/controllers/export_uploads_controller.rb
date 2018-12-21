class ExportUploadsController < ApplicationController
  # include PolicyChecker
  # include RansackDateFilter
  # include IevInterfaces
  skip_before_action :authenticate_user!, only: [:upload]
  skip_before_action :verify_authenticity_token, only: [:upload]
  # defaults resource_class: Export::Base, collection_name: 'exports', instance_name: 'export'

  def upload
    resource = Export::Base.find params[:id]
    if params[:token] == resource.token_upload
      resource.file = params[:file]
      resource.save!
      render json: {status: :ok}
    else
      user_not_authorized
    end
  end
end
