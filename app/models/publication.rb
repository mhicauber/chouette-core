class Publication < ActiveRecord::Base
  extend Enumerize

  enumerize :status, in: %w[new pending successful failed running successful_with_warnings], default: :new

  belongs_to :publication_setup
  belongs_to :export, class_name: 'Export::Base'
  belongs_to :parent, polymorphic: true
  has_many :reports, class_name: 'DestinationReport', dependent: :destroy

  validates :publication_setup, :parent, presence: true

  after_create :publish

  status.values.each do |s|
    define_method "#{s}!" do
      update status: s
    end

    define_method "#{s}?" do
      status.to_s == s
    end
  end

  def running!
    update_columns status: :running, started_at: Time.now
  end

  %i[failed successful successful_with_warnings].each do |s|
    define_method "#{s}!" do
      update status: s, ended_at: Time.now
    end
  end

  def publish
    pending!
    if parent.successful?
      PublicationWorker.perform_async_or_fail(self)
    else
      failed!
    end
  end

  def pretty_date
    I18n.l(created_at)
  end

  def name
    self.class.tmf('name', setup_name: publication_setup.name, date: pretty_date)
  end

  def run
    running!
    run_export
  rescue
    failed!
  end

  def run_export
    begin
      export = publication_setup.new_export
      export.referential = parent.new
      export.save!
    rescue
      failed!
      return
    ensure
      update export: export
    end

    unless export.successful?
      failed!
      return
    end

    send_to_destinations
    infer_status
  end

  def send_to_destinations
    publication_setup.destinations.each { |destination| destination.transmit(self) }
  end

  def infer_status
    new_status = reports.all?(&:successful?) ? :successful : :successful_with_warnings
    send("#{new_status}!")
  end

  def export_output
    export&.file
  end
end
