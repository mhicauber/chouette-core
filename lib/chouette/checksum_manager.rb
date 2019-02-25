module Chouette::ChecksumManager
  extend Chouette::Logger

  THREAD_VARIABLE_NAME = "current_checksum_manager".freeze

  class NotInTransactionError < StandardError; end
  class AlreadyInTransactionError < StandardError; end
  class MultipleReferentialsError < StandardError; end

  def self.current
    current_manager = Thread.current.thread_variable_get THREAD_VARIABLE_NAME
    current_manager || self.current = Chouette::ChecksumManager::Inline.new
  end

  def self.current= manager
    Thread.current.thread_variable_set THREAD_VARIABLE_NAME, manager
    manager
  end

  def self.logger_prefix
    "ChecksumManager::#{current.class.name.split('::').last} #{current.object_id.to_s(16)}"
  end

  def self.start_transaction
    return unless transaction_enabled?

    raise AlreadyInTransactionError if in_transaction?
    self.current = Chouette::ChecksumManager::Transactional.new
    log "=== NEW TRANSACTION ==="
  end

  def self.in_transaction?
    current.is_a?(Chouette::ChecksumManager::Transactional)
  end

  def self.commit
    return unless transaction_enabled?

    current.log "=== COMMITTING TRANSACTION ==="
    raise NotInTransactionError unless in_transaction?
    current.commit
    log "=== DONE COMMITTING TRANSACTION ==="
    self.current = nil
  end

  def self.after_create object
    current.after_create object
  end

  def self.after_destroy object
    current.after_destroy object
  end

  def self.transaction_enabled?
    Rails.application.config.enable_transactional_checksums
  end

  def self.transaction
    start_transaction
    out = yield
    commit
    out
  end

  def self.watch object, from: nil
    current.watch object, from: from
  end

  def self.object_signature object
    SerializedObject.new(object).signature
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
          if object.association(belongs_to.intern).loaded?
            log "parent is already loaded"
            parent = object.send(belongs_to)
            parents << SerializedObject.new(parent, need_save: true, load_object: true) if parent
          else
            log "parent is not loaded but can be inferred from reflection"
            parent_id = object.send(reflection.foreign_key)
            parent_class = reflection.klass.name
          end
        else
          # the relation is not a true ActiveRecord Relation
          log "parent has to be loaded"
          parent = object.send(belongs_to)
          parents << [parent.class.name, parent.id]
        end
        parents << [parent_class, parent_id] if parent_id
      end

      if object.respond_to? has_many
        # XXX: SOME OPTIM POSSIBLE HERE
        if reflection && object.association(has_many.intern).loaded?
          log "parents are already loaded"
          parents += object.send(has_many).map{|p| SerializedObject.new(p, need_save: true)}
        else
          if reflection && !reflection.options[:through]
            log "parent are not loaded but can be inferred from reflection"
            parents += [reflection.klass.name].product(object.send(has_many).pluck(reflection.foreign_key).compact)
          else
            log "parents have to be loaded"
            # the relation is not a true ActiveRecord Relation
            parents += object.send(has_many).map { |p| SerializedObject.new(p, need_save: true, load_object: true)}
          end
        end
      end
    end
    parents.compact
  end

  def self.parents_to_sentence parents
    parents.map do |p|
      if p.is_a?(Array)
        p
      elsif p.respond_to?(:serialized_object)
        p.serialized_object
      else
       [p.class.name, p.id]
     end
    end.group_by(&:first).map{ |klass, v| "#{v.size} #{klass}" }.to_sentence
  end

  def self.child_after_save object
    if object.changed? || object.destroyed?
      parents = checksum_parents object
      log "Request from #{object.class.name}##{object.id} checksum updates for #{parents.count} parent(s): #{parents_to_sentence(parents)}"
      parents.each { |parent| watch parent, from: object }
    end
  end

  def self.child_before_destroy object
    parents = checksum_parents object

    log "Prepare request for #{object.class.name}##{object.id} deletion checksum updates for #{parents.count} parent(s): #{parents_to_sentence(parents)}"

    @_parents_for_checksum_update ||= {}
    @_parents_for_checksum_update[object_signature(object)] = parents
  end

  def self.child_after_destroy object
    if @_parents_for_checksum_update.present? && @_parents_for_checksum_update[object_signature(object)].present?
      parents = @_parents_for_checksum_update[object_signature(object)]
      log "Request from #{object.class.name}##{object.id} checksum updates for #{parents.count} parent(s): #{parents_to_sentence(parents)}"
      parents.each { |parent| Chouette::ChecksumManager.watch parent, from: object }
      @_parents_for_checksum_update.delete object
    end
  end
end
