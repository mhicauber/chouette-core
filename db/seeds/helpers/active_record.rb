class ActiveRecord::Base
  def self.seed_by(key_attribute, &block)
    model = find_or_initialize_by key_attribute
    print "Seed #{name} #{key_attribute.inspect} "
    yield model

    status = if model.new_record?
      'created'
    elsif model.changed?
      'updated'
    else
      'no change'
    end
    puts "[#{status}]"
    unless model.save
      puts "Can't save #{model.class.name} : #{model.errors.inspect}"
      raise ActiveRecord::RecordNotSaved.new("Invalid #{model.class.name} : #{model.errors.inspect}")
    end

    model
  end
end
