require 'dns/dns'
require 'json'
require 'globodns_client'

module Proxy::Dns::GloboDNS
  class Record < ::Proxy::Dns::Record
    include Proxy::Log
    include Proxy::Util

    attr_reader :auth_token, :host

    def self.record(attrs = {})
      new(attrs.merge(
        :auth_token => ::Proxy::Dns::GloboDNS::Plugin.settings.auth_token,
        :host => ::Proxy::Dns::GloboDNS::Plugin.settings.host,
      ))
    end

    def initialize options = {}
      @auth_token = options[:auth_token]
      @host = options[:host]
      raise "dns_globodns provider needs 'auth_token' and 'host' options" unless @auth_token && @host
      super(options)
    end

    def create
      if @type.eql?('A')
        query = @fqdn
        value = @value
      elsif @type.eql?('PTR')
        query = @value
        value = @fqdn
      else
        raise "Not Implemented"
      end
      begin
        conn.new_record(query, @type, value)
      rescue GlobodnsClient::AlreadyExists
        raise(Proxy::Dns::Collision, "#{@fqdn} is already used")
      end
      true
    end

    def remove
      query = @type.eql?('A') ? @fqdn : @value
      begin
        conn.delete_record(query, @type)
      rescue GlobodnsClient::NotFound
        raise(Proxy::Dns::NotFound, "#{@fqdn} not found")
      end
      true
    end

    private

    def conn
      @conn ||= GlobodnsClient::Connection.new(auth_token: @auth_token, host: @host)
    end

  end
end
