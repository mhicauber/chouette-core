class ComplianceCheckBlock < ApplicationModel
  include NetexTransportModeEnumerations
  include NetexTransportSubmodeEnumerations

  belongs_to :compliance_check_set

  has_many :compliance_checks, dependent: :nullify

  store_accessor :condition_attributes,
    :transport_mode,
    :transport_submode

  validate :transport_mode_and_submode_match

  def lines_scope(compliance_check)
    scope = compliance_check.referential.lines
    if transport_submode
      scope = scope.where(transport_submode: transport_submode)
    elsif transport_mode
      scope = scope.where(transport_mode: transport_mode)
    end
    scope
  end
end
