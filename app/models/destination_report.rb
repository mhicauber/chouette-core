class DestinationReport < ActiveRecord::Base
  extend Enumerize

  belongs_to :destination
  belongs_to :publication

  validates :destination, :publication, presence: true

  enumerize :status, in: %w[successful failed], empty: true

  def start!
    update started_at: Time.now
  end

  def failed!
    update ended_at: Time.now, status: :failed
  end

  def success!
    update ended_at: Time.now, status: :successful
  end
end
