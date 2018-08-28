Cron.every_5_minutes :check_import_operations, :check_ccset_operations
Cron.every_day_at_3AM AuditMailer.audit().deliver if AuditMailer.enabled?
Cron.every_day_at_3AM ReferentialAudit.::Full.new.push_to_slack if AF83::Slack.enabled?
