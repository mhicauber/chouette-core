class ComplianceControlBlock < ApplicationModel
  include NetexTransportModeEnumerations
  include NetexTransportSubmodeEnumerations

  belongs_to :compliance_control_set
  has_many :compliance_controls, dependent: :destroy

  store_accessor :condition_attributes,
    :block_kind,
    :transport_mode, :transport_submode,
    :country, :min_stop_areas_in_country

  validates :transport_mode, presence: true, if: :transport_mode?
  validates :country, :min_stop_areas_in_country, presence: true, if: :stop_areas_in_countries?
  validates :compliance_control_set, presence: true

  validate :transport_mode_and_submode_match

  validates_uniqueness_of :condition_attributes, scope: :compliance_control_set_id

  def stop_areas_in_countries?
    block_kind.to_s == "stop_areas_in_countries"
  end

  def transport_mode?
    block_kind.to_s == "transport_mode"
  end

  def name
    if transport_mode?
      ApplicationController.helpers.transport_mode_text(self)
    else
      'compliance_control_blocks.stop_areas_in_countries'.t(country_name: ISO3166::Country[country].translation, min_count: min_stop_areas_in_country)
    end
  end
end
