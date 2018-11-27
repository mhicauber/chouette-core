class ComplianceControlBlock < ApplicationModel
  include NetexTransportModeEnumerations
  include NetexTransportSubmodeEnumerations

  belongs_to :compliance_control_set
  has_many :compliance_controls, dependent: :destroy

  store_accessor :condition_attributes,
    :transport_mode,
    :transport_submode

  validates :transport_mode, presence: true
  validates :compliance_control_set, presence: true

  validate :transport_mode_and_submode_match

  validates_uniqueness_of :condition_attributes, scope: :compliance_control_set_id

  def name
    ApplicationController.helpers.transport_mode_text(self)
  end

end
