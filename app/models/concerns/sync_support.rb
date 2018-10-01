module SyncSupport
  extend ActiveSupport::Concern

  included do
    @keep_syncs = 40

    class << self
      attr_accessor :keep_syncs
    end
  end

  def clean_previous_syncs(sync_type)
    collection = send(sync_type)
    return unless collection.count > self.class.keep_syncs
    while collection.count > self.class.keep_syncs do
      collection.order("created_at asc").first.destroy
    end
  end
end
