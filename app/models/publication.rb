class Publication < ActiveRecord::Base
  belongs_to :publication_setup
  belongs_to :export
  belongs_to :parent, polymorphic: true
  has_many :reports, class_name: 'DestinationReport', dependent: :destroy

  validates :publication_setup, :parent, presence: true
end
