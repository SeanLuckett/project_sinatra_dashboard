source 'https://rubygems.org'

ruby '2.4.1'

gem 'activesupport', '~> 5.0.0'
gem 'google-api-client'
gem 'mechanize', '~> 2.7.5'
gem 'sinatra', '~> 2.0.0'
gem 'sinatra-contrib'
gem 'thin'

group :development do
  gem 'envyable', '~> 1.2.0'
  gem 'pry', '~> 0.10.4'
end

group :test do
  gem 'capybara'

  # temp ruby 2.4.1 incompatibility fix until fakeweb publishes master branch to rubygems
  gem 'fakeweb', github: 'chrisk/fakeweb', branch: 'master'

  gem 'rack-test', require: 'rack/test'
  gem 'rspec', '~> 3.6.0'
end
