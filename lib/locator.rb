require 'httparty'

class Locator
  LOC_URL = 'freegeoip.net'.freeze
  FORMAT = 'json'.freeze

  def initialize(ip_addr)
    @request = HTTParty.get "http://#{LOC_URL}/#{FORMAT}/#{ip_addr}"
  end

  def json
    @json ||= @request.body
  end
end