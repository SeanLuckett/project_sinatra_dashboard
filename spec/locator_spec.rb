require 'fakeweb'

RSpec.describe Locator do
  let(:ip) { '173.239.240.72' }
  let(:locator) { Locator.new(ip) }

  before do
    url = URI("http://#{Locator::LOC_URL}/#{Locator::FORMAT}/#{ip}")
    FakeWeb.register_uri(:get,
                         url.path,
                         body: expected_json,
                         content_type: 'application/json')
  end

  it 'gets user location' do
    expect(HTTParty).to receive(:get).with "http://freegeoip.net/json/#{ip}"
    Locator.new(ip)
  end

  it 'returns the json location payload' do
    expect(locator.json).to eq expected_json.to_json << "\n"
  end

  def expected_json
    {
      ip: ip,
      country_code: 'US',
      country_name: 'United States',
      region_code: 'IL',
      region_name: 'Illinois',
      city: 'Chicago',
      zip_code: '60602',
      time_zone: 'America/Chicago',
      latitude: 41.8483,
      longitude: -87.6517,
      metro_code: 602
    }
  end
end
