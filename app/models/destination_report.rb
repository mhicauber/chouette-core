class DestinationReport < ActiveRecord::Base
  extend Enumerize

  belongs_to :destination
  belongs_to :publication

  validates :destination, :publication, presence: true

  enumerize :status, in: %w[successful failed], empty: true

  def start!
    update started_at: Time.now
  end

  %w[successful failed].each do |s|
    define_method "#{s}?" do
      status.to_s == s
    end
  end

  def failed! message: nil, backtrace: nil
    update ended_at: Time.now, status: :failed, error_message: message, error_backtrace: backtrace.to_json
  end

  def success!
    update ended_at: Time.now, status: :successful
  end
end
