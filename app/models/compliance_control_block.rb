class ComplianceControlBlock < ApplicationModel
  include ComplianceBlockSupport

  belongs_to :compliance_control_set
  has_many :compliance_controls, dependent: :destroy

  validates_uniqueness_of :condition_attributes, scope: :compliance_control_set_id
  validates :compliance_control_set, presence: true

  def name
    if transport_mode?
      ApplicationController.helpers.transport_mode_text(self)
    else
      'compliance_control_blocks.stop_areas_in_countries'.t(country_name: ISO3166::Country[country].translation(I18n.locale), min_count: min_stop_areas_in_country)
    end
  end
end
