require File.expand_path('../boot', __FILE__)

ENV['RANSACK_FORM_BUILDER'] = '::SimpleForm::FormBuilder'

require 'rails/all'
require_relative '../lib/chouette_env'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ChouetteIhm
  class Application < Rails::Application

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.autoload_paths << config.root.join('lib')

    # custom exception pages
    config.exceptions_app = self.routes

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Paris'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    ChouetteEnv.add :IEV_URL
    ChouetteEnv.add :RAILS_DB_ADAPTER, default: :postgis
    ChouetteEnv.add :RAILS_DB_HOST, default: 'db'
    ChouetteEnv.add :RAILS_DB_NAME, default: 'chouette'
    ChouetteEnv.add :RAILS_DB_PASSWORD
    ChouetteEnv.add :RAILS_DB_POOLSIZE, default: '40'
    ChouetteEnv.add :RAILS_DB_PORT, default: '5432'
    ChouetteEnv.add :RAILS_DB_USER, default: 'chouette'
    ChouetteEnv.add :RAILS_HOST
    ChouetteEnv.add :RAILS_LOCALE, default: :fr
    ChouetteEnv.add :SIDEKIQ_REDIS_URL, default: 'redis://localhost:6379/12'
    ChouetteEnv.add :TEST_ENV_NUMBER
    ChouetteEnv.add :WORKBENCH_IMPORT_DIR
    ChouetteEnv.add_boolean :AUTOMATED_AUDITS_ENABLED
    ChouetteEnv.add_boolean :BYPASS_AUTH_FOR_SIDEKIQ
    ChouetteEnv.add_boolean :CHOUETTE_ROUTE_POSITION_CHECK
    ChouetteEnv.add_boolean :CHOUETTE_ITS_SEND_INVITATION
    ChouetteEnv.add_boolean :NO_TRANSACTION
    ChouetteEnv.add_boolean :SUBSCRIPTION_NOTIFIER_ENABLED
    ChouetteEnv.add_boolean :CHOUETTE_SIDEKIQ_CANCEL_SYNCS_ON_BOOT

    # IEVKIT
    ChouetteEnv.add :IEVKIT_ACCESS_TOKEN
    ChouetteEnv.add :IEVKIT_API_ENDPOINT
    ChouetteEnv.add :IEVKIT_AUTO_PAGINATE
    ChouetteEnv.add :IEVKIT_CLIENT_ID
    ChouetteEnv.add :IEVKIT_DEFAULT_MEDIA_TYPE
    ChouetteEnv.add :IEVKIT_LOGIN
    ChouetteEnv.add :IEVKIT_NETRC_FILE
    ChouetteEnv.add :IEVKIT_PASSWORD
    ChouetteEnv.add :IEVKIT_PER_PAGE
    ChouetteEnv.add :IEVKIT_PROXY
    ChouetteEnv.add :IEVKIT_SECRET
    ChouetteEnv.add :IEVKIT_USER_AGENT
    ChouetteEnv.add :IEVKIT_WEB_ENDPOINT
    ChouetteEnv.add_boolean :IEVKIT_NETRC
    ChouetteEnv.add_boolean :IEVKIT_SILENT

    # Cucumber
    ChouetteEnv.add :CUCUMBER_FORMAT

    config.i18n.default_locale = ChouetteEnv[:RAILS_LOCALE].to_sym

    # Configure Browserify to use babelify to compile ES6
    # config.browserify_rails.commandline_options = "-t [ babelify --presets [ react es2015 ] ]"

    config.active_record.observers = [:route_observer, :calendar_observer]
    config.active_record.raise_in_transactional_callbacks = true

    config.active_job.queue_adapter = :sidekiq

    config.action_dispatch.rescue_responses.merge!(
      'FeatureChecker::NotAuthorizedError' => :unauthorized
    )

    config.development_toolbar = false
    config.enable_calendar_observer = true
    config.enable_subscriptions_notifications = ChouetteEnv.boolean('SUBSCRIPTION_NOTIFIER_ENABLED')
    config.subscriptions_notifications_recipients = []
    config.enable_automated_audits = ChouetteEnv.boolean('AUTOMATED_AUDITS_ENABLED')
    config.automated_audits_recipients = []

    config.vehicle_journeys_extra_headers = []
    config.osm_backgrounds_source = :osm
    config.osm_backgrounds_esri_token = "your_token_here"

    unless Rails.env.production?
        # Work around sprockets+teaspoon mismatch:
        Rails.application.config.assets.precompile += %w(spec_helper.js)
        # Make sure Browserify is triggered when
        # asked to serve javascript spec files
        # config.browserify_rails.paths << lambda { |p|
        #     p.start_with?(Rails.root.join("spec/javascripts").to_s)
        # }
    end
  end
end
