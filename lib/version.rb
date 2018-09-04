module Version

  def self.reset
    @version = @version_parsed = nil
  end

  def self.current
    unless @version_parsed
      @version ||= parse_version_file || get_git_version
      @version_parsed = true
    end
    @version
  end

  protected
  def self.get_git_version
    res = [
      get_branch_name,
      get_commit_name
    ]
    res.all?(&:present?) && res.map(&:strip).join(' ') || nil
  rescue => e
    Rails.logger.warn "Error parsing version from git: #{e.message}"
    nil
  end

  def self.get_branch_name
    %x(git symbolic-ref --short HEAD)
  end

  def self.get_commit_name
    %x(git log -1 --pretty=%h)
  end

  def self.parse_version_file
    content = read_version_file
    parsed_content = content && JSON.parse(content)
    parsed_content.try :[], "build_name"
  rescue => e
    Rails.logger.warn "Error parsing version file: #{e.message}"
    nil
  end

  def self.read_version_file
    filepath = File.join(Rails.root, "config", "version.json")
    if File.exists?(filepath)
      File.read filepath
    else
      nil
    end
  end
end
