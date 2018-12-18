class PublicationSetup < ApplicationModel
  belongs_to :workgroup
  has_many :publications
  has_many :destinations

  validates :workgroup, presence: true
  validates :export_type, presence: true
end
