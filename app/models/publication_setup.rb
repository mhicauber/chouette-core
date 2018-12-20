class PublicationSetup < ApplicationModel
  belongs_to :workgroup
  has_many :publications, dependent: :destroy
  has_many :destinations, dependent: :destroy

  validates :name, presence: true
  validates :workgroup, presence: true
  validates :export_type, presence: true

  accepts_nested_attributes_for :destinations, allow_destroy: true, reject_if: :all_blank

  def export_class
    export_type.presence&.safe_constantize || Export::Base
  end

  def new_export
    export_class.new(options: export_options)
  end
end
