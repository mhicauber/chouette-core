class ComplianceControlSet < ActiveRecord::Base
  belongs_to :organisation
  has_many :compliance_controls
end
