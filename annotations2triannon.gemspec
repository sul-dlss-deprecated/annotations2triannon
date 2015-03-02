# -*- encoding: utf-8 -*-
#lib = File.expand_path('../lib/', __FILE__)
#$:.unshift lib unless $:.include?(lib)

Gem::Specification.new do |s|
  s.name        = 'annotations2triannon'
  s.version     = '0.1.0'
  s.licenses    = ['Apache-2.0']
  s.platform    = Gem::Platform::RUBY

  s.authors     = ['Darren Weber',]
  s.email       = ['darren.weber@stanford.edu']

  s.homepage    = 'https://github.com/sul-dlss/triannon'
  s.summary     = 'bulk load annotations into triannon'
  s.description = 'Utilities for bulk loading annotations into triannon'

  s.required_rubygems_version = '>= 1.3.6'

  # s.extra_rdoc_files = ['README.md', 'LICENSE']

  # general utils
  s.add_dependency 'json'
  s.add_dependency 'uuid'
  # Use ENV for config
  s.add_dependency 'dotenv'
  # HTTP and RDF linked data
  s.add_dependency 'addressable', '~> 2.3'
  s.add_dependency 'linkeddata', '~> 1.0'
  s.add_dependency 'rdf-open_annotation'
  s.add_dependency 'rest-client', '~> 1.0'
  # Use pry for console and debug config
  s.add_dependency 'pry'
  s.add_dependency 'pry-doc'
  # performance utils
  s.add_dependency 'parallel', '~> 1.0'
  s.add_dependency 'ruby-progressbar', '~> 1.0'
  # database gems
  s.add_dependency 'mysql2'
  s.add_dependency 'sequel'

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'guard'
  s.add_development_dependency 'guard-ctags-bundler'


  s.files   = `git ls-files`.split($/)
  dev_files = %w(.gitignore bin/setup.sh bin/test.sh)
  dev_files.each {|f| s.files.delete f }

  s.executables = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files  = s.files.grep(%r{^(test|spec|features)/})

end

