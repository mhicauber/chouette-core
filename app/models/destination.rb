class Destination < ApplicationModel
  include OptionsSupport

  belongs_to :publication_setup
  has_many :reports, class_name: 'DestinationReport'

  validates :name, :type, :publication_setup, presence: true

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
end
