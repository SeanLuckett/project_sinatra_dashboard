require 'open-uri'
require 'fakeweb'

RSpec.describe JobScraper do
  let(:terms) { 'herp derp' }
  let(:scraper) do
    JobScraper.new(
      search_terms: terms
    )
  end

  before :all do
    test_file_path = File.join(File.dirname(__FILE__), 'assets/dice_denver_jobs.html')
    stream = open(test_file_path, &:read)
    url_search_terms = 'herp_derp'
    url = "#{JobScraper::DICE_SEARCH_URL_BEGIN}#{url_search_terms}#{JobScraper::DICE_SEARCH_URL_END}"

    FakeWeb.register_uri(:get,
                         url,
                         body: stream,
                         content_type: 'text/html')
  end

  describe 'parsing' do
    describe 'results' do
      let(:job) { scraper.listings.first }

      it 'has a job title' do
        expected_title = 'High Paying Full Stack Engineer ( React/Rails)'
        expect(job).to have_attributes title: expected_title
      end

      it 'has a company name' do
        expected_id = 'CyberCoders'
        expect(job).to have_attributes company_name: expected_id
      end

      it 'has a job url' do
        expected_link = 'https://www.dice.com/jobs/detail/High-Paying-Full-Stack-Engineer-%28-React%26%2347Rails%29-CyberCoders-Denver-CO-80201/cybercod/KE2%26%2345134123371?icid=sr2-1p&q=rails full stack web&l=Denver, CO'
        expect(job).to have_attributes link: expected_link
      end

      it 'has a company id' do
        expected_id = 'cybercod'
        expect(job).to have_attributes company_id: expected_id
      end

      it 'has a job id' do
        expected_id = URI.unescape('KE2%26%2345134123371')
        expect(job).to have_attributes job_id: expected_id
      end

      it 'has a location' do
        expected_loc = 'Denver, CO'
        expect(job).to have_attributes location: expected_loc
      end

      it 'has a posting date' do
        expected_date = 8.hours.ago.strftime('%a, %b %d, %Y')
        expect(job).to have_attributes posted_on: expected_date
      end
    end
  end
end