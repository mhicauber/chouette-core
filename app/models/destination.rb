class Destination < ApplicationModel
  include OptionsSupport

  belongs_to :publication_setup
  has_many :reports, class_name: 'DestinationReport', dependent: :destroy

  validates :name, :type, presence: true

  mount_uploader :secret_file, SecretFileUploader
  validates :secret_file, presence: true, if: :secret_file_required?

  @secret_file_required = false

  class << self
    def secret_file_required?
      !!@secret_file_required
    end

    def enabled?(destination_type)
      Rails.application.config.additional_destinations.try :include?, destination_type
    end
  end

  def secret_file_required?
    self.class.secret_file_required?
  end

  def transmit(publication)
    report = reports.find_or_create_by(publication_id: publication.id)
    report.start!
    begin
      do_transmit publication, report
      report.success! unless report.failed?
    rescue => e
      report.failed! message: e.message, backtrace: e.backtrace
    end
  end

  def do_transmit(publication, report)
    raise NotImplementedError
  end

  def human_type
    self.class.human_type
  end

  def self.human_type
    self.ts
  end

  def local_temp_file(uploader)
    url = "#{SmartEnv['RAILS_HOST']}#{uploader.url}"
    content = open(url).read.force_encoding('utf-8')

    tmp = Tempfile.new [name, "#{File.extname uploader.path}"]
    tmp.write content
    tmp.rewind
    tmp
  end

  def local_secret_file
    return unless self[:secret_file].present?

    local_temp_file secret_file
  end

  private
  def self.custom_i18n_key
    model_name.to_s.underscore.gsub('/', '.')
  end
end

require_dependency './destination/dummy' if ::Destination.enabled?("dummy")
require_dependency './destination/google_cloud_storage'
require_dependency './destination/sftp'
