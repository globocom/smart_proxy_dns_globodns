require 'smart_proxy_dns_globodns/dns_globodns_version'

module Proxy::Dns::GloboDNS
  class Plugin < ::Proxy::Provider
    plugin :dns_globodns, ::Proxy::Dns::GloboDNS::VERSION,
           :factory => proc { |attrs| ::Proxy::Dns::GloboDNS::Record.record(attrs) }

    requires :dns, '>= 1.10'

    after_activation do
      require 'smart_proxy_dns_globodns/dns_globodns_main'
    end
  end
end
