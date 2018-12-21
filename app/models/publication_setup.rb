class PublicationSetup < ApplicationModel
  belongs_to :workgroup
  has_many :publications, dependent: :destroy
  has_many :destinations, dependent: :destroy

  validates :name, presence: true
  validates :workgroup, presence: true
  validates :export_type, presence: true

  accepts_nested_attributes_for :destinations, allow_destroy: true, reject_if: :all_blank

  scope :enabled, -> { where enabled: true }

  def export_class
    export_type.presence&.safe_constantize || Export::Base
  end

  def new_export
    export_class.new(options: export_options).tap do |export|
      export.name = "#{self.class.ts} #{name}"
      export.creator = "#{self.class.ts} #{name}"
      export.synchronous = true
    end
  end

  def publish(operation)
    publications.create!(parent: operation)
  end
end
