source 'https://rubygems.org'

ruby RUBY_VERSION if ENV['CI']

gem 'rake'
gem 'tins', '< 1.7'

group :test do
  gem 'rspec', '~> 3.1'
  gem 'rspec-its'
  gem 'coveralls'
  gem 'timecop'
end

group :development do
  gem 'yard', '~> 0.8.6'
  gem 'redcarpet', platform: :ruby
end

# Specify your gem's dependencies in ruby-path.gemspec
gemspec
