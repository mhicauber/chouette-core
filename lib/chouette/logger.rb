module Chouette::Logger
  def logger
    @@logger ||= Rails.logger
  end

  def logger= logger
    @@logger = logger
  end

  def log_level
    @@log_level ||= :debug
  end

  def log_level= log_level
    @@log_level = log_level if logger.respond_to?(log_level)
  end

  def logger_prefix
    nil
  end

  def log msg
    msg = "[#{logger_prefix}] #{msg}" if logger_prefix
    logger.send log_level, msg
  end
end
