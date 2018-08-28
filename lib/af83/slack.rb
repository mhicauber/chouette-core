class AF83::Slack
  def self.enabled?
    Rails.application.config.slack_webhook_enabled
  end

  def self.push message, opts={}
    return unless enabled?
    channel = opts.delete(:channel) || "monitoring_chouette"
    username = opts.delete(:username) || "chouette-bot"
    notifier = Slack::Notifier.new Rails.application.config.slack_webhook_url, channel: channel, username: username
    notifier.post ({text: message}).update(opts)
  end
end
