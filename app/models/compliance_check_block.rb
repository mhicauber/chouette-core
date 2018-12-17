class ComplianceCheckBlock < ApplicationModel
  include NetexTransportModeEnumerations
  include NetexTransportSubmodeEnumerations

  belongs_to :compliance_check_set

  has_many :compliance_checks, dependent: :nullify

  store_accessor :condition_attributes,
    :transport_mode,
    :transport_submode

  validate :transport_mode_and_submode_match
end
