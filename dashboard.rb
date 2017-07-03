require 'sinatra/base'
require 'sinatra/reloader'

class ScraperDashboard < Sinatra::Application
  configure :development do
    register Sinatra::Reloader
  end

  get '/' do
    'Hello world!'
  end
end