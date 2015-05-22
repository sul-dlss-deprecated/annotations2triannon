# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name        = 'annotations2triannon'
  s.version     = '0.4.0'
  s.licenses    = ['Apache-2.0']
  s.platform    = Gem::Platform::RUBY

  s.authors     = ['Darren Weber',]
  s.email       = ['triannon-commits@lists.stanford.edu']

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
  s.add_dependency 'addressable'
  s.add_dependency 'linkeddata'
  # HTTP client and rack cache components
  s.add_dependency 'triannon-client'
  s.add_dependency 'rest-client'
  s.add_dependency 'rest-client-components'
  s.add_dependency 'rack-cache'
  # dalli is a memcached ruby client
  s.add_dependency 'dalli'
  # Use pry for console and debug config
  s.add_dependency 'pry'
  s.add_dependency 'pry-doc'
  # database gems
  s.add_dependency 'mysql2'
  s.add_dependency 'sequel'
  # cache simple RDF on redis
  s.add_dependency 'hiredis'
  s.add_dependency 'redis'

  s.add_development_dependency 'coveralls'
  s.add_development_dependency 'guard'
  s.add_development_dependency 'guard-ctags-bundler'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'

  git_files = `git ls-files`.split($/)
  bin_files = %w(bin/console bin/ctags.rb bin/setup.sh bin/test.sh)
  dot_files = %w(.gitignore .travis.yml log/.gitignore)
  s.files = git_files - (bin_files + dot_files)
  s.executables = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files  = s.files.grep(%r{^(test|spec|features)/})

end

