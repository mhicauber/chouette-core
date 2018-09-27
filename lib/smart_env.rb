module SmartEnv
  EXPLICITLY_FALSE_VALUES = [0, "0", "false", "no"]

  def self.keys
    @keys ||= []
  end

  def self.default_values
    @default_values ||= {}
  end

  def self.required_keys
    @required_keys ||= []
  end

  def self.boolean_keys
    @boolean_keys ||= []
  end

  def self.reset!
    @keys = nil
    @required_keys = nil
    @boolean_keys = nil
    @default_values = nil
  end

  def self.set key, opts={}
    self.add key, opts
  end

  def self.add key, opts={}
    key = key.to_s
    keys << key unless keys.include?(key)
    if opts.has_key?(:required)
      required_keys.delete key
      required_keys << key if opts[:required]
    end
    if opts.has_key?(:boolean)
      boolean_keys.delete key
      boolean_keys << key if opts[:boolean]
    end
    if opts.has_key?(:default)
      default_values[key] = opts[:default]
    end
  end

  def self.add_required key, opts={}
    self.add key, opts.update({required: true})
  end

  def self.add_boolean key, opts={}
    self.add key, opts.update({boolean: true})
  end

  def self.check!
    required_keys.each do |k|
      raise MissingKey.new("Missing mandatory ENV key `#{k}`") unless ENV.has_key?(k)
    end
  end

  def self.[] key
    self.fetch(key)
  end

  def self.boolean key, opts={}
    self.fetch key, opts.update({boolean: true})
  end

  def self.fetch key, opts={}
    key = key.to_s
    unless keys.include?(key)
      logger.warn("Fetching unexpected ENV key `#{key}`")
      keys << key
    end

    default = nil
    default = opts[:default] if opts.has_key?(:default)
    default = yield if block_given?

    val = ENV.fetch(key, nil) || default || default_values[key]
    val = cast_boolean(val) if opts[:boolean] || boolean_keys.include?(key)
    val
  end

  @@default_logger = nil
  def self.default_logger
    @@default_logger ||= Logger.new($stdout)
  end

  def self.logger
    Rails.logger || default_logger
  end

  def self.cast_boolean value
    value = value.downcase if value.is_a?(String)
    return false if EXPLICITLY_FALSE_VALUES.include?(value)
    return value.present? if value.is_a?(String)
    !!value
  end

  class MissingKey < Exception
  end
end
