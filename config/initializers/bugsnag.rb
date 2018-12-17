Bugsnag.configure do |config|
  config.api_key = SmartEnv.fetch('BUGSNAG_API_KEY')
end
