source 'https://rubygems.org'

ruby RUBY_VERSION if ENV['CI']

gem 'rake'

group :test do
  gem 'rspec', '>= 3.0.0.beta1'
  gem 'rspec-its'
  gem 'coveralls'
  gem 'timecop'
end

group :development do
  gem 'yard', '~> 0.8.6'
  gem 'listen'
  gem 'guard-yard'
  gem 'guard-rspec'
  gem 'redcarpet', platform: :ruby
end

# Specify your gem's dependencies in ruby-path.gemspec
gemspec
