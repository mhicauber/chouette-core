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
    prepare_referential
  end

  def prepare_referential
    # import_resources :lines

    create_referential
    referential.switch
  end

  def referential_metadata
    # TODO #10176
    line_ids = line_referential.lines.pluck :id

    # TODO #10177
    periode = (Time.now..1.month.from_now)
    ReferentialMetadata.new line_ids: line_ids, periodes: [periode]
  end
end
