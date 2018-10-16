module AF83::ChecksumManager
  class Base
    def object_signature object
      AF83::ChecksumManager.object_signature object
    end

    def after_create object
    end

    def after_destroy object
    end

    def log msg
      AF83::ChecksumManager.log msg
    end

    def update_object_synchronously object, force_save: false
      serialized_object = SerializedObject.new(object, load_object: true)
      if serialized_object.need_save || force_save
        serialized_object.object.update_checksum_without_callbacks!
      else
        serialized_object.object.set_current_checksum_source
        serialized_object.object.update_checksum
      end
    end
  end
end
