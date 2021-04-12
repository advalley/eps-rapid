# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EpsRapid::Recommendations do
  before :all do
    EpsRapid.configure do |config|
      config.api_key      = 'mock-api-key'
      config.secret_key   = 'mock-api-secret'
      config.base_path    = 'https://test.ean.com/2.4'
      config.language     = 'en-US'
    end
  end

  describe '#recommendations' do
    it 'should return recommendations list' do
      stub_request(
        :get,
        'https://test.ean.com/2.4/properties/availability?language=en-US&checkin=2021-05-20&'\
        'checkout=2021-05-22&destination_iata_airport_code=SEA&currency=USD&country_code=US&'\
        'occupancy=2&sales_channel=website&sales_environment=hotel_package&rate_plan_count=1'
      ).with(
        headers: {
          'Accept' => 'application/json',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Authorization' => EpsRapid.auth_header,
          'Content-Type' => 'application/json',
          'Host' => 'test.ean.com',
          'User-Agent' => 'Ruby'
        }
      ).to_return(status: 200, body: File.read('spec/fixtures/recommendations.txt'))

      response = EpsRapid::Recommendations.recommendations(
        checkin: '2021-05-20', checkout: '2021-05-22',
        destination_iata_airport_code: 'SEA', currency: 'USD',
        country_code: 'US', occupancy: '2',
        sales_channel: 'website', sales_environment: 'hotel_package',
        rate_plan_count: 1
      )

      expect(response).to be_kind_of(Array)
      expect(response.first).to have_key('property_id')
      expect(response.first).to have_key('rooms')
    end
  end

  describe '#altervative_recommendations' do
    it 'should return alternative recommendations list' do
      stub_request(
        :get,
        'https://test.ean.com/2.4/properties/availability?language=en-US&checkin=2021-05-20&'\
        'checkout=2021-05-22&destination_iata_airport_code=SEA&currency=USD&country_code=US&'\
        'occupancy=2&sales_channel=website&sales_environment=hotel_package&rate_plan_count=1&'\
        'reference_property_id=50947'
      ).with(
        headers: {
          'Accept' => 'application/json',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Authorization' => EpsRapid.auth_header,
          'Content-Type' => 'application/json',
          'Host' => 'test.ean.com',
          'User-Agent' => 'Ruby'
        }
      ).to_return(status: 200, body: File.read('spec/fixtures/alternative_recommendations.txt'))

      response = EpsRapid::Recommendations.recommendations(
        checkin: '2021-05-20', checkout: '2021-05-22',
        destination_iata_airport_code: 'SEA', currency: 'USD',
        country_code: 'US', occupancy: '2',
        sales_channel: 'website', sales_environment: 'hotel_package',
        rate_plan_count: 1, reference_property_id: '50947'
      )

      expect(response).to be_kind_of(Array)
      expect(response.first).to have_key('property_id')
      expect(response.first).to have_key('rooms')
    end
  end
end
