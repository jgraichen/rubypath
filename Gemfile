# frozen_string_literal: true

source 'https://rubygems.org'

ruby RUBY_VERSION if ENV['CI']

gem 'rake'

group :test do
  gem 'coveralls'
  gem 'rspec', '~> 3.1'
  gem 'rspec-its'
  gem 'timecop'
end

group :development do
  gem 'redcarpet', platform: :ruby
  gem 'rubocop'
  gem 'yard', '~> 0.9.9'
end

# Specify your gem's dependencies in ruby-path.gemspec
gemspec
