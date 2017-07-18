require 'sinatra/base'
require 'sinatra/reloader'
require_relative 'vendor/job_scraper'
require_relative 'lib/locator'
require_relative 'vendor/google/sheets_job_storage'

class ScraperDashboard < Sinatra::Application
  enable :sessions

# Avoid warning: http://stackoverflow.com/a/18047653/5113832
  set :session_secret, '*&(^B234'

  configure :development do
    register Sinatra::Reloader
  end

  helpers do
    def user_ip
      :development ? '75.171.196.183' : request.ip
    end
  end

  set :views, File.expand_path('../views', __FILE__)

  get '/' do
    session.clear
    locator = Locator.new(user_ip)
    session[:user_loc] = locator.json

    erb :index
  end

  post '/save-job-listings' do
    # TODO: implement
  end

  post '/search-jobs' do
    user_location = JSON.parse(session[:user_loc])

    scraper = JobScraper.new(
      search_terms: params[:search_terms],
      city: user_location['city'],
      state: user_location['region_code'],
      writer: SheetsJobStorage
    )

    erb :results, locals: {
      job_listings: scraper.listings,
      search_terms: params[:search_terms]
    }
  end
end