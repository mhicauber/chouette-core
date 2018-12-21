class Destination < ApplicationModel
  include OptionsSupport

  belongs_to :publication_setup
  has_many :reports, class_name: 'DestinationReport', dependent: :destroy

  validates :name, :type, :publication_setup, presence: true

  mount_uploader :secret_file, SecretFileUploader

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
    self.class.ts
  end

  private
  def self.custom_i18n_key
    model_name.to_s.underscore.gsub('/', '.')
  end
end

require_dependency './destination/dummy'
