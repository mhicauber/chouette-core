class Destination::GoogleCloudStorage < ::Destination
  require "google/cloud/storage"

  option :project, required: true
  option :bucket, required: true

  @secret_file_required = true

  def do_transmit(publication, report)
    publication.exports.each do |export|
      upload_to_google_cloud export.file
    end
  end

  def upload_to_google_cloud file
    storage = Google::Cloud::Storage.new(
      project_id: self.project,
      credentials: local_secret_file.path
    )

    bucket = storage.bucket self.bucket, skip_lookup: true
    bucket.create_file file.path, File.basename(file.path)
  end
end
