module AF83::ChecksumManager
  def self.watch object, opts={}
    current.watch object, opts
  end

  def self.current
    @current ||= AF83::ChecksumManager::Inline.new
  end

  class Inline
    def watch object, opts
      if opts.delete(:save)
        object.update_checksum_without_callbacks!
      else
        object.set_current_checksum_source
        object.update_checksum
      end
    end
  end
end
