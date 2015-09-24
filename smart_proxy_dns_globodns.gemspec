require File.expand_path('../lib/smart_proxy_dns_globodns/dns_globodns_version', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'smart_proxy_dns_globodns'
  s.version     = Proxy::Dns::GloboDNS::VERSION
  s.license     = 'GPLv3'
  s.authors     = ['Ernesto Thorp']
  s.email       = ['ernesto@corp.globo.com']
  s.homepage    = 'https://github.com/globocom/smart_proxy_dns_globodns'

  s.summary     = "GloboDNS provider plugin for Foreman's smart proxy"
  s.description = "GloboDNS provider plugin for Foreman's smart proxy - https://github.com/globocom/GloboDNS"

  s.files       = Dir['{config,lib,bundler.d}/**/*'] + ['README.md', 'LICENSE']
  s.test_files  = Dir['test/**/*']

  s.add_dependency('globodns_client', '>= 0.1.1')

  s.add_development_dependency('rake')
  s.add_development_dependency('mocha')
  s.add_development_dependency('test-unit')
end
