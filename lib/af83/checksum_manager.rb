module AF83::ChecksumManager
  def self.watch object, opts={}
    current.watch object, opts
  end

  def self.current
    @current ||= AF83::ChecksumManager::Inline.new
  end

  class Base
    def resolve_object object
      if object.is_a? ActiveRecord::Base
        [object, false]
      else
        [object.first.constantize.find(object.last), true]
      end
    end
  end

  class Inline < Base

    # We update the checksums right away
    def watch object, opts
      object, need_save = *resolve_object(object)
      if need_save
        object.update_checksum_without_callbacks!
      else
        object.set_current_checksum_source
        object.update_checksum
      end
    end
  end
end
