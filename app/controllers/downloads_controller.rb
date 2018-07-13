class DownloadsController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :reject_unauthenticated_user!

  def download
    file = File.open File.join(Rails.root, "uploads", params[:path]) + ".#{params[:extension]}"
    send_file file
  rescue Errno::ENOENT
    not_found
  end

  protected
  def reject_unauthenticated_user!
    user_not_authorized unless current_user.present?
  end
end
