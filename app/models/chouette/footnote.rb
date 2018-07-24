module Chouette
  class Footnote < Chouette::ActiveRecord
    include ChecksumSupport

    belongs_to :line, inverse_of: :footnotes
    has_and_belongs_to_many :vehicle_journeys, :class_name => 'Chouette::VehicleJourney'

    scope :associated, -> {
      joins(:vehicle_journeys).where("vehicle_journeys.id is not null")
    }

    scope :not_associated, -> {
      joins('LEFT JOIN "footnotes_vehicle_journeys" ON footnotes_vehicle_journeys.footnote_id = footnotes.id')
      .where("footnotes_vehicle_journeys.vehicle_journey_id is null")
    }

    validates_presence_of :line

    def checksum_attributes
      attrs = ['code', 'label']
      self.slice(*attrs).values
    end
  end
end
