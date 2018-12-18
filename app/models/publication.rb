class Publication < ActiveRecord::Base
  belongs_to :publication_setup
  belongs_to :export
  belongs_to :parent, polymorphic: true

  validates :publication_setup, :parent, presence: true
end
