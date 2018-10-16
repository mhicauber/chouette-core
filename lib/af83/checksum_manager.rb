module AF83::ChecksumManager
  THREAD_VARIABLE_NAME = "current_checksum_manager".freeze

  class NotInTransactionError < StandardError; end
  class AlreadyInTransactionError < StandardError; end
  class MultipleReferentialsError < StandardError; end

  def self.current
    current_manager = Thread.current.thread_variable_get THREAD_VARIABLE_NAME
    current_manager || self.current = AF83::ChecksumManager::Inline.new
  end

  def self.current= manager
    Thread.current.thread_variable_set THREAD_VARIABLE_NAME, manager
    manager
  end

  def self.logger
    @@logger ||= Rails.logger
  end

  def self.logger= logger
    @@logger = logger
  end

  def self.log_level
    @@log_level ||= :debug
  end

  def self.log_level= log_level
    @@log_level = log_level if logger.respond_to?(log_level)
  end

  def self.log msg
    prefix = "[ChecksumManager::#{current.class.name.split('::').last} #{current.object_id.to_s(16)}]"
    logger.send log_level, "#{prefix} #{msg}"
  end

  def self.start_transaction
    raise AlreadyInTransactionError if in_transaction?
    log "=== NEW TRANSACTION ==="
    self.current = AF83::ChecksumManager::Transactional.new
  end

  def self.in_transaction?
    current.is_a?(AF83::ChecksumManager::Transactional)
  end

  def self.commit
    current.log "=== COMMITTING TRANSACTION ==="
    raise NotInTransactionError unless current.is_a?(AF83::ChecksumManager::Transactional)
    current.commit
    log "=== DONE COMMITTING TRANSACTION ==="
    self.current = nil
  end

  def self.after_create object
    current.after_create object
  end

  def self.transaction
    start_transaction
    yield
    commit
  end

  def self.watch object, from: nil
    current.watch object, from: from
  end

  def self.checksum_parents object
    klass = object.class
    return [] unless klass.respond_to? :checksum_parent_relations
    return [] unless klass.checksum_parent_relations

    parents = []
    klass.checksum_parent_relations.each do |parent_model, opts|
      belongs_to = opts[:relation] || parent_model.model_name.singular
      has_many = opts[:relation] || parent_model.model_name.plural

      if object.respond_to? belongs_to
       reflection = klass.reflections[belongs_to.to_s]
       if reflection
         parent_id = object.send(reflection.foreign_key)
         parent_class = reflection.klass.name
       else
         # the relation is not a true ActiveRecord Relation
         parent = object.send(belongs_to)
         parents << [parent.class.name, parent.id]
       end
       parents << [parent_class, parent_id] if parent_id
     end
     if object.respond_to? has_many
       reflection = klass.reflections[has_many.to_s]
       if reflection
         parents += [reflection.klass.name].product(object.send(has_many).pluck(reflection.foreign_key).compact)
       else
         # the relation is not a true ActiveRecord Relation
         parents += object.send(has_many).map {|parent| [parent.class.name, parent.id] }
       end
     end
    end
    parents.compact
  end

  def self.parents_to_sentence parents
    parents.group_by(&:first).map{ |klass, v| "#{v.size} #{klass}" }.to_sentence
  end

  def self.child_update_parents object
    if object.changed? || object.destroyed?
      parents = checksum_parents object
      log "Request from #{object.class.name}##{object.id} checksum updates for #{parents.count} parent(s): #{parents_to_sentence(parents)}"
      parents.each { |parent| watch parent, from: object }
    end
  end

  def self.child_load_parents object
    parents = checksum_parents object

    log "Prepare request for #{object.class.name}##{object.id} deletion checksum updates for #{parents.count} parent(s): #{parents_to_sentence(parents)}"

    @_parents_for_checksum_update ||= {}
    @_parents_for_checksum_update[object] = parents
  end

  def self.child_update_loaded_parents object
    if @_parents_for_checksum_update.present? && @_parents_for_checksum_update[object].present?
      parents = @_parents_for_checksum_update[object]
      log "Request from #{object.class.name}##{object.id} checksum updates for #{parents.count} parent(s): #{parents_to_sentence(parents)}"
      parents.each { |parent| AF83::ChecksumManager.watch parent, from: object }
      @_parents_for_checksum_update.delete object
    end
  end

  class SerializedObject
    def self.new object, opts={}
      return object if object.is_a?(SerializedObject)
      super object, opts
    end

    def initialize original_object, opts={}
      @serialized_object = serialize_object(original_object)
      if original_object.is_a?(ActiveRecord::Base)
        # in case we have a new AR::Base, we store it already
        # this prevent errors if the object is not persisted yet
        @object = original_object unless original_object.persisted? && !opts[:load_object]
        @need_save = false
      else
        @need_save = true
      end
    end

    def signature opts={}
      unserialized = object&.to_s
      return unserialized if opts[:unserialized]
      @signature ||= (@serialized_object.last.present? ? @serialized_object.join('_') : unserialized)
    end

    def reload
      @object&.reload
    end

    def need_save
      @need_save
    end

    def object_class
      @object_class ||= @serialized_object.first.constantize
    end

    def serialized_object
      @serialized_object
    end

    def object
      @object ||= resolve_object @serialized_object
    end

    def resolve_object object
      return object if object.is_a? ActiveRecord::Base
      object.first.constantize.find(object.last)
    end

    def serialize_object object
      return [object.class.name, object.id] if object.is_a? ActiveRecord::Base
      object
    end
  end

  class Base
    def after_create object
    end

    def log msg
      AF83::ChecksumManager.log msg
    end

    def update_object_synchronously object, force_save: false
      serialized_object = SerializedObject.new(object)
      if serialized_object.need_save || force_save
        serialized_object.object.update_checksum_without_callbacks!
      else
        serialized_object.object.set_current_checksum_source
        serialized_object.object.update_checksum
      end
    end
  end

  class Inline < Base
    # We update the checksums right away
    def watch object, _
      update_object_synchronously object
    end
  end

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
      ensure_tenant_did_not_change!
      push_on_stack SerializedObject.new(object), from
      if from.nil?
        # we are in the before_save callback
        mark_dirty object
      end
    end

    def commit
      begin
        return if resolution_stack.empty?
        Apartment::Tenant.switch @current_tenant do
          sentinel = resolution_stack.size ** 2 # If I'm correct, the max complexity here is n(n+1)/2
          object = resolution_stack.shift
          while object && sentinel > 0
            count = resolution_children_count[object.signature]
            log "resolving checksum for #{object.signature}: #{count} pending children"
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
              AF83::ChecksumManager.child_load_parents(object.object).each do |parent|
                resolution_children_count[SerializedObject.new(parent).signature] -= 1
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
      @dirty_objects = nil
    end

    def after_create object
      log "after_create #{object}"
      serialized = SerializedObject.new(object, load_object: true)
      new_signature = SerializedObject.new(serialized.serialized_object).signature
      count = resolution_children_count.delete(serialized.signature(unserialized: true)) || 0

      # we cannot just use `watch` here, because we want to keep a reference on the AR object
      resolution_stack.push serialized
      resolution_children_count[new_signature] = count
    end

    protected

    def resolution_stack
      @resolution_stack ||= []
    end

    def resolution_children_count
      @resolution_children_count ||= {}
    end

    def dirty_objects
      @dirty_objects ||= Hash.new { |hash, key| hash[key] = [] }
    end

    def mark_dirty object
      dirty_objects[SerializedObject.new(object).signature].push object
    end

    def is_dirty? object
      dirty_objects.key? SerializedObject.new(object).signature
    end

    def dirty_object_instances object
      dirty_objects[SerializedObject.new(object).signature]
    end

    def push_on_stack object, from
      unless resolution_children_count.has_key?(object.signature)
        resolution_stack.push object
      end

      resolution_children_count[object.signature] ||= 0

      if from && from.class.try(:is_checksum_enabled?)
        resolution_children_count[object.signature] += 1
      end
    end
  end
end
