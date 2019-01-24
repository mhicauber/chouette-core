class Import::Neptune < Import::Base
  include LocalImportSupport

  def self.accepts_file?(file)
    Zip::File.open(file) do |zip_file|
      zip_file.glob('*.xml').size == zip_file.glob('*').size
    end
  rescue => e
    Rails.logger.debug "Error in testing Neptune file: #{e}"
    return false
  end

  def launch_worker
    NeptuneImportWorker.perform_async_or_fail(self)
  end

  def import_without_status
  end
end
