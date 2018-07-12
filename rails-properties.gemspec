# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rails-properties/version'

Gem::Specification.new do |gem|
  gem.name          = 'rails-properties'
  gem.version       = RailsProperties::VERSION
  gem.licenses      = ['MIT']
  gem.authors       = ['Fletcher Fowler']
  gem.email         = ['fletch@fzf.me']
  gem.description   = %q{Properties gem for Ruby on Rails}
  gem.summary       = %q{Ruby gem to handle properties for ActiveRecord instances by storing them as serialized Hash in a separate database table. Namespaces and defaults included.}
  gem.homepage      = 'https://github.com/1debit/rails-properties'
  gem.required_ruby_version = '>= 1.9.3'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_dependency 'activerecord', '>= 3.1'

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'sqlite3'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'coveralls'
  gem.add_development_dependency 'simplecov', RUBY_VERSION < '2' ? '~> 0.11.2' : '>= 0.11.2'
end
