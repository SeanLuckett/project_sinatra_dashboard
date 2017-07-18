require 'mechanize'
require 'active_support/time'

class JobScraper
  DICE_SEARCH_URL_BEGIN = 'https://www.dice.com/jobs/jtype-Full%20Time-q-'.freeze
  DICE_SEARCH_URL_END = '-l-Denver%2C_CO-radius-10-jobs'.freeze
  DICE_JOB_CSS = '.complete-serp-result-div'.freeze
  GOOGLE_SHEET_NAME = 'Dice'

  attr_reader :listings

  def initialize(scraper: Mechanize.new, search_terms:, writer:)
    @page = scraper.get(
      "#{DICE_SEARCH_URL_BEGIN}#{search_terms.gsub(/\s+/, '_')}" \
      "#{DICE_SEARCH_URL_END}"
    )

    @listings = parse_jobs
    @Writer = writer
  end

  def parse_jobs
    job_listings.each_with_index.map do |job, i|
      parse_job(job, i)
    end
  end

  private

  def job_listings
    @page.css DICE_JOB_CSS
  end

  def extract_location(job)
    job.css('ul.details li.location').first['title']
  end

  def extract_posting_date(job)
    date_string = job.css('ul.details li.posted').first.content
    date_command_string = date_string.split(' ').join('.')

    date_command_string = '10.minutes.ago' if date_command_string =~ /moments/

    begin
      date = eval(date_command_string)
    rescue StandardError => e
      puts "Error: #{e.message}"
    end

    date.strftime('%a, %b %d, %Y')
  end

  def parse_from_url(url)
    url_obj = URI(url)
    path_parts = url_obj.path.split('/')
    company_id = URI.unescape(path_parts[-2])
    job_id = URI.unescape(path_parts.last)

    [company_id, job_id]
  end

  def parse_job(job, index)
    position_info = job.css("a#position#{index}").first
    title = position_info['title']
    link = position_info['href']
    company_id, job_id = parse_from_url(link)

    company_name = job.css("a#company#{index}").first.children.first.text
    location = extract_location(job)

    date = extract_posting_date(job)


    JobListing.new(title, company_name, location,
                   link, company_id, job_id, date)
  end

  def write_data(job_data_array)
    @Writer.save_job GOOGLE_SHEET_NAME, job_data_array
  end
end

JobListing = Struct.new(:title, :company_name, :location, :link,
                        :company_id, :job_id, :posted_on)