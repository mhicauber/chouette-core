module SyncSupport
  extend ActiveSupport::Concern
  KEEP_SYNCS = 40

  def clean_previous_syncs(sync_type)
    return unless send(sync_type).count > KEEP_SYNCS
    while send(sync_type).count > KEEP_SYNCS do
      send(sync_type).order("created_at asc").first.destroy
    end
  end
end