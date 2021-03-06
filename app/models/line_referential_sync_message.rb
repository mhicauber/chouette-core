class LineReferentialSyncMessage < ApplicationModel
  belongs_to :line_referential_sync
  enum criticity: [:info, :warning, :error]

  validates :criticity, presence: true
end
