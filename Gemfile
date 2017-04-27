source 'https://rubygems.org'

ruby RUBY_VERSION if ENV['CI']

gem 'rake'

group :test do
  gem 'rspec', '~> 3.1'
  gem 'rspec-its'
  gem 'coveralls'
  gem 'timecop'
end

group :development do
  gem 'yard', '~> 0.9.9'
  gem 'redcarpet', platform: :ruby
  gem 'rubocop'
end

# Specify your gem's dependencies in ruby-path.gemspec
gemspec
