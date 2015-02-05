# -*- encoding: utf-8 -*-
#lib = File.expand_path('../lib/', __FILE__)
#$:.unshift lib unless $:.include?(lib)

Gem::Specification.new do |s|
  s.name        = "annotations2triannon"
  s.version     = '0.1.0'
  s.licenses    = ['Apache-2.0']
  s.platform    = Gem::Platform::RUBY
  
  s.authors     = ['Darren Weber',]
  s.email       = ['darren.weber@stanford.edu']

  s.homepage    = "There is no HOMEPAGE"
  s.summary     = "Utilities for bulk loading annotations into triannon"
  s.description = "Utilities for bulk loading annotations into triannon"

  s.required_rubygems_version = ">= 1.3.6"

  # s.extra_rdoc_files = ['README.md', 'LICENSE']

  # Use ENV for config
  s.add_dependency 'dotenv'

  # Use pry for console and debug config
  s.add_dependency 'pry'
  s.add_dependency 'pry-doc'
  s.add_dependency 'ruby-progressbar'

  s.add_dependency 'json'
  s.add_dependency 'linkeddata'

  s.add_development_dependency 'rspec'

  s.files   = `git ls-files`.split($/)
  dev_files = %w(.gitignore bin/setup.sh bin/test.sh)
  dev_files.each {|f| s.files.delete f }

  s.executables = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files  = s.files.grep(%r{^(test|spec|features)/})

end

