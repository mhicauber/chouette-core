class Destination < ApplicationModel
  belongs_to :publication_setup

  validates :name, :type, :publication_setup, presence: true
end
