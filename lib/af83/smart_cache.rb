class AF83::SmartCache
  DEFAULT_MAX_SIZE = 50

  def initialize(opts = {})
    @max_size = opts[:max_size] || DEFAULT_MAX_SIZE
    @last_entries = []
    @_entries = {}
  end

  def size
    @_entries.size
  end

  def fetch(key)
    val = @_entries[key] ||= begin
      @last_entries << key
      yield
    end
    clean_entries
    val
  end

  protected

  def clean_entries
    @_entries.delete(@last_entries.shift) while size > @max_size
  end
end
