class ComplianceControl < ActiveRecord::Base
  belongs_to :compliance_control_set
  belongs_to :compliance_control_block

  extend Enumerize
  enumerize :criticity, in: %i(info warning error), scope: true, default: :info

  validates :criticity, presence: true
  validates :name, presence: true
  validates :code, presence: true
  validates :compliance_control_set, presence: true

  def self.policy_class
    ComplianceControlPolicy
  end
end

# Ensure STI subclasses are loaded
# http://guides.rubyonrails.org/autoloading_and_reloading_constants.html#autoloading-and-sti
require_dependency 'generic_attribute_min_max'
