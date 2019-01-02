module ComplianceBlockSupport
  extend ActiveSupport::Concern

  included do
    include NetexTransportModeEnumerations
    include NetexTransportSubmodeEnumerations

    store_accessor :condition_attributes,
      :block_kind,
      :transport_mode, :transport_submode,
      :country, :min_stop_areas_in_country

    validates :block_kind, presence: true
    validates :transport_mode, presence: true, if: :transport_mode?
    validates :country, :min_stop_areas_in_country, presence: true, if: :stop_areas_in_countries?

    validate :transport_mode_and_submode_match, if: :transport_mode?
  end

  def stop_areas_in_countries?
    block_kind.to_s == "stop_areas_in_countries"
  end

  def transport_mode?
    block_kind.to_s == "transport_mode"
  end
end
