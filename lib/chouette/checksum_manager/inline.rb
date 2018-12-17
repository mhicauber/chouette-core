module Chouette::ChecksumManager  
  class Inline < Base
    # We update the checksums right away
    def watch object, _
      log "watch: #{object_signature(object)}"
      update_object_synchronously object
    end
  end
end
