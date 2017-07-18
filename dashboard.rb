require 'sinatra/base'
require 'sinatra/reloader'
require_relative 'vendor/job_scraper'
require_relative 'vendor/google/sheets_job_storage'

class ScraperDashboard < Sinatra::Application
  enable :sessions

# Avoid warning: http://stackoverflow.com/a/18047653/5113832
  set :session_secret, '*&(^B234'

  configure :development do
    register Sinatra::Reloader
  end

  set :views, File.expand_path('../views', __FILE__)

  get '/' do
    session.clear
    erb :index
  end

  post '/save-job-listings' do
    # TODO: implement
  end

  post '/search-jobs' do
    scraper = JobScraper.new(
      search_terms: params[:search_terms],
      writer: SheetsJobStorage
    )

    erb :results, locals: {
      job_listings: scraper.listings,
      search_terms: params[:search_terms]
    }
  end
end