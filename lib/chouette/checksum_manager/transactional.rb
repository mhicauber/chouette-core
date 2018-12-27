module Chouette::ChecksumManager
  class Transactional < Base
    def initialize
      @current_tenant = Apartment::Tenant.current
    end

    def ensure_tenant_did_not_change!
      unless Apartment::Tenant.current == @current_tenant
        abort_transaction!
        raise MultipleReferentialsError
      end
    end

    def watch object, from: nil
      log "watch: #{object_signature(object)} from: #{from.inspect}"
      ensure_tenant_did_not_change!
      push_on_stack SerializedObject.new(object, load_object: from.nil?), from
      if from.nil?
        # we are in the before_save callback
        mark_dirty object
      end
    end

    def commit
      begin
        return if resolution_stack.empty?
        Apartment::Tenant.switch @current_tenant do
          # If I'm correct, the max complexity here is n(n+1)/2
          # The +1 is to prevent an error when te stack contains a single element
          sentinel = (resolution_stack.size + 1) ** 2
          object = resolution_stack.shift
          while object && sentinel > 0
            count = resolution_children_count[object.signature]&.size
            if count
              log "resolving checksum for #{object.signature}: #{count} children"
            else
              log "resolving checksum for #{object.signature}: NOT FOUND"
            end
            if count.nil?
              # the object no longer exists (most likely a new record that is now saved with another signature)
              log "SKIP OBJECT"
            elsif count.zero?
              if is_dirty?(object)
                log "Reloading dirty object"
                object.reload
              end
              log "Updating"
              update_object_synchronously object, force_save: true
              dirty_object_instances(object).map(&:reload)
              Chouette::ChecksumManager.checksum_parents(object.object).each do |parent|
                resolution_children_count[SerializedObject.new(parent).signature].delete object.signature
              end
            else
              log "Pushed back"
              resolution_stack.push object
            end
            sentinel -= 1
            object = resolution_stack.shift
          end
          raise "There was an error processing the resolution queue" unless sentinel > 0
        end
      ensure
        clean!
      end
    end

    def abort_transaction!
      log "=== ABORTING TRANSACTION ==="
      clean!
    end

    def clean!
      @resolution_stack = nil
      @resolution_children_count = nil
      @resolution_stack_indexes = nil
      @dirty_objects = nil
    end

    def after_create object
      log "after_create #{object}"
      serialized = SerializedObject.new(object, load_object: true)
      new_signature = SerializedObject.new(serialized.serialized_object).signature
      old_signature = serialized.signature(unserialized: true)
      count = resolution_children_count.delete(old_signature) || 0

      # we cannot just use `watch` here, because we want to keep a reference on the AR object
      resolution_children_count[new_signature] = count
      if resolution_stack_indexes[new_signature]
        # this object is already in the stack, we replace it
        resolution_stack[resolution_stack_indexes[new_signature]] = self
      else
        resolution_stack_indexes[new_signature] = resolution_stack.size
        resolution_stack.push serialized
      end
    end

    def after_destroy object
      log "after_destroy #{object}"
      dirty_objects.delete object_signature(object)
    end

    protected

    def resolution_stack
      @resolution_stack ||= []
    end

    def resolution_stack_indexes
      @resolution_stack_indexes ||= {}
    end

    def resolution_children_count
      @resolution_children_count ||= {}
    end

    def dirty_objects
      @dirty_objects ||= Hash.new { |hash, key| hash[key] = [] }
    end

    def mark_dirty object
      dirty_objects[object_signature(object)].push(object)
    end

    def is_dirty? object
      signature = object_signature(object)
      dirty_objects.key?(signature) && dirty_objects[signature].size > 1
    end

    def dirty_object_instances object
      dirty_objects[object_signature(object)]
    end

    def push_on_stack object, from
      if resolution_stack_indexes.has_key?(object.signature)
        # we substitute the object in the stack,
        # to ensure we are using the most recent data
        resolution_stack[resolution_stack_indexes[object.signature]] = object
      else
        resolution_stack_indexes[object.signature] = resolution_stack.size
        resolution_stack.push object
      end

      resolution_children_count[object.signature] ||= Set.new

      if from && from.class.try(:is_checksum_enabled?) && !from.destroyed?
        resolution_children_count[object.signature] << object_signature(from)
      end
    end
  end
end
