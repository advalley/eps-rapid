# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EpsRapid::Notifications do
  before :all do
    EpsRapid.configure do |config|
      config.api_key      = 'mock-api-key'
      config.secret_key   = 'mock-api-secret'
      config.base_path    = 'https://test.ean.com/2.4'
      config.language     = 'en-US'
    end
  end

  describe '#test_notification_event' do
    it 'should return 204 status' do
      stub_request(:get, 'https://test.ean.com/2.4/notifications/itinerary.agent.create?language=en-US')
        .with(
          headers: {
            'Accept' => 'application/json',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Authorization' => EpsRapid.auth_header,
            'Content-Type' => 'application/json',
            'Host' => 'test.ean.com',
            'User-Agent' => 'Ruby'
          }
        ).to_return(status: 204)

      response = EpsRapid::Notifications.test_notification_event('itinerary.agent.create')

      expect(response).to include('Code: 204, No content')
    end
  end

  describe '#undeliverable_notifications' do
    it 'should return notifications list' do
      stub_request(:get, 'https://test.ean.com/2.4/notifications/undeliverable?language=en-US')
        .with(
          headers: {
            'Accept' => 'application/json',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Authorization' => EpsRapid.auth_header,
            'Content-Type' => 'application/json',
            'Host' => 'test.ean.com',
            'User-Agent' => 'Ruby'
          }
        ).to_return(status: 200, body: File.read('spec/fixtures/undeliverable_notification.txt'))

      response = EpsRapid::Notifications.undeliverable_notifications

      expect(response).to be_kind_of(Array)
      expect(response.first).to have_key('event_id')
      expect(response.first).to have_key('itinerary_id')
      expect(response.first).to have_key('email')
      expect(response.first).to have_key('message')
    end
  end
end
