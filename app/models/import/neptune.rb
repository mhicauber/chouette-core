class Import::Neptune < Import::Base
  include ImportResourcesSupport

  def self.accepts_file?(file)
    Zip::File.open(file) do |zip_file|
      zip_file.glob('*.xml').size == zip_file.glob('*').size
    end
  rescue => e
    Rails.logger.debug "Error in testing Neptune file: #{e}"
    return false
  end
end
