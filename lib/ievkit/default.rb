require 'ievkit/response/raise_error'
require 'ievkit/version'

module Ievkit

  # Default configuration options for {Client}
  module Default

    # Default API endpoint
    API_ENDPOINT = "http://localhost:8080/chouette_iev/".freeze

    # Default User Agent header string
    USER_AGENT   = "Ievkit Ruby Gem #{Ievkit::VERSION}".freeze

    # Default media type
    MEDIA_TYPE   =  "" # "application/vnd.iev.v1.0+json".freeze

    # Default WEB endpoint
    WEB_ENDPOINT = "http://localhost:3000".freeze

    # Default page sie
    PER_PAGE = 12

    # In Faraday 0.9, Faraday::Builder was renamed to Faraday::RackBuilder
    RACK_BUILDER_CLASS = defined?(Faraday::RackBuilder) ? Faraday::RackBuilder : Faraday::Builder

    # Default Faraday middleware stack
    MIDDLEWARE = RACK_BUILDER_CLASS.new do |builder|
      builder.use Faraday::Request::Multipart

      builder.use Ievkit::Response::RaiseError
      builder.use FaradayMiddleware::FollowRedirects
      #builder.use Faraday::Response::Logger

      builder.adapter Faraday.default_adapter
    end

    class << self

      # Configuration options
      # @return [Hash]
      def options
        Hash[Ievkit::Configurable.keys.map{|key| [key, send(key)]}]
      end

      # Default access token from ENV
      # @return [String]
      def access_token
        SmartEnv['IEVKIT_ACCESS_TOKEN']
      end

      # Default API endpoint from ENV or {API_ENDPOINT}
      # @return [String]
      def api_endpoint
        SmartEnv['IEVKIT_API_ENDPOINT'] || API_ENDPOINT
      end

      # Default pagination preference from ENV
      # @return [String]
      def auto_paginate
        SmartEnv['IEVKIT_AUTO_PAGINATE']
      end

      # Default OAuth app key from ENV
      # @return [String]
      def client_id
        SmartEnv['IEVKIT_CLIENT_ID']
      end

      # Default OAuth app secret from ENV
      # @return [String]
      def client_secret
        SmartEnv['IEVKIT_SECRET']
      end

      # Default options for Faraday::Connection
      # @return [Hash]
      def connection_options
        {
          :headers => {
            :accept => default_media_type,
            :user_agent => user_agent
          }
        }
      end

      # Default media type from ENV or {MEDIA_TYPE}
      # @return [String]
      def default_media_type
        SmartEnv['IEVKIT_DEFAULT_MEDIA_TYPE'] || MEDIA_TYPE
      end

      # Default Iev username for Basic Auth from ENV
      # @return [String]
      def login
        SmartEnv['IEVKIT_LOGIN']
      end

      # Default middleware stack for Faraday::Connection
      # from {MIDDLEWARE}
      # @return [String]
      def middleware
        MIDDLEWARE
      end

      # Default Iev password for Basic Auth from ENV
      # @return [String]
      def password
        SmartEnv['IEVKIT_PASSWORD']
      end

      # Default pagination page size from ENV
      # @return [Fixnum] Page size
      def per_page
        page_size = SmartEnv['IEVKIT_PER_PAGE'] || PER_PAGE

        page_size.to_i if page_size
      end

      # Default proxy server URI for Faraday connection from ENV
      # @return [String]
      def proxy
        SmartEnv['IEVKIT_PROXY']
      end

      # Default User-Agent header string from ENV or {USER_AGENT}
      # @return [String]
      def user_agent
        SmartEnv['IEVKIT_USER_AGENT'] || USER_AGENT
      end

      # Default web endpoint from ENV or {WEB_ENDPOINT}
      # @return [String]
      def web_endpoint
        SmartEnv['IEVKIT_WEB_ENDPOINT'] || WEB_ENDPOINT
      end

      # Default behavior for reading .netrc file
      # @return [Boolean]
      def netrc
        SmartEnv['IEVKIT_NETRC']
      end

      # Default path for .netrc file
      # @return [String]
      def netrc_file
        SmartEnv['IEVKIT_NETRC_FILE'] || File.join(ENV['HOME'].to_s, '.netrc')
      end

    end
  end
end
