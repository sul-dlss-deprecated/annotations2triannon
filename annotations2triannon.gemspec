# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name        = 'annotations2triannon'
  s.version     = '0.1.0'
  s.licenses    = ['Apache-2.0']
  s.platform    = Gem::Platform::RUBY

  s.authors     = ['Darren Weber',]
  s.email       = ['darren.weber@stanford.edu']

  s.homepage    = 'https://github.com/sul-dlss/annotations2triannon'
  s.summary     = 'bulk load annotations into triannon'
  s.description = 'Utilities for bulk loading annotations into triannon'

  s.required_rubygems_version = '>= 1.3.6'

  s.extra_rdoc_files = ['README.md', 'LICENSE']

  # general utils
  s.add_dependency 'json'
  s.add_dependency 'uuid'
  # Use ENV for config
  s.add_dependency 'dotenv'
  # RDF linked data
  s.add_dependency 'addressable', '~> 2.3'
  s.add_dependency 'linkeddata', '~> 1.0'
  s.add_dependency 'rdf-iiif'
  # HTTP client and rack cache components
  s.add_dependency 'triannon-client'
  s.add_dependency 'rest-client', '~> 1.8.0'
  s.add_dependency 'rest-client-components', '~> 1.4.0'
  s.add_dependency 'rack-cache', '~> 1.2'
  # dalli is a memcached ruby client
  s.add_dependency 'dalli', '~> 2.7.2'
  # Use pry for console and debug config
  s.add_dependency 'pry'
  s.add_dependency 'pry-doc'
  # database gems
  s.add_dependency 'mysql2'
  s.add_dependency 'sequel'

  s.add_development_dependency 'coveralls'
  s.add_development_dependency 'guard'
  s.add_development_dependency 'guard-ctags-bundler'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'

  s.files   = `git ls-files`.split($/)
  dev_files = %w(.gitignore bin/console bin/ctags.rb bin/setup.sh bin/test.sh)
  dev_files.each {|f| s.files.delete f }

  s.executables = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files  = s.files.grep(%r{^(test|spec|features)/})

end

