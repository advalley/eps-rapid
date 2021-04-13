# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EpsRapid::ManageBooking do
  before :all do
    EpsRapid.configure do |config|
      config.api_key      = 'mock-api-key'
      config.secret_key   = 'mock-api-secret'
      config.base_path    = 'https://test.ean.com/2.4'
      config.language     = 'en-US'
    end
  end

  describe '#retrieve_bookings' do
    it 'should return bookings list' do
      stub_request(
        :get,
        'https://test.ean.com/2.4/itineraries?email=test@example.com&affiliate_reference_id=4480ABCQXCZS&language=en-US'
      ).with(
        headers: {
          'Accept' => 'application/json',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Authorization' => EpsRapid.auth_header,
          'Content-Type' => 'application/json',
          'Host' => 'test.ean.com',
          'User-Agent' => 'Ruby',
          'Customer-Ip' => '127.0.0.1'
        }
      ).to_return(status: 200, body: File.read('spec/fixtures/bookings_list.txt'))

      response = EpsRapid::ManageBooking.retrieve_bookings(
        email: 'test@example.com',
        affiliate_reference_id: '4480ABCQXCZS',
        customer_ip: '127.0.0.1'
      )

      expect(response).to be_kind_of(Array)
      expect(response.first).to have_key('itinerary_id')
      expect(response.first).to have_key('rooms')
      expect(response.first['email']).to eq('test@example.com')
    end

    it 'should return error if affiliate_reference_id is empty' do
      stub_request(
        :get,
        'https://test.ean.com/2.4/itineraries?email=test@example.com&language=en-US'
      ).with(
        headers: {
          'Accept' => 'application/json',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Authorization' => EpsRapid.auth_header,
          'Content-Type' => 'application/json',
          'Host' => 'test.ean.com',
          'User-Agent' => 'Ruby',
          'Customer-Ip' => '127.0.0.1'
        }
      ).to_return(status: 400, body: File.read('spec/fixtures/retrieve_bookings_invalid.txt'))

      expect do
        EpsRapid::ManageBooking.retrieve_bookings(
          email: 'test@example.com',
          customer_ip: '127.0.0.1'
        )
      end.to raise_error(EpsRapid::Exceptions::BadRequestError, 'Code: 400, Error: Affiliate reference id is required.')
    end
  end

  describe '#retrieve_booking' do
    it 'should return booking by email' do
      stub_request(
        :get,
        'https://test.ean.com/2.4/itineraries/7372514319381?email=test@example.com&language=en-US'
      ).with(
        headers: {
          'Accept' => 'application/json',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Authorization' => EpsRapid.auth_header,
          'Content-Type' => 'application/json',
          'Host' => 'test.ean.com',
          'User-Agent' => 'Ruby',
          'Customer-Ip' => '127.0.0.1'
        }
      ).to_return(status: 200, body: File.read('spec/fixtures/booking_retrieved.txt'))

      response = EpsRapid::ManageBooking.retrieve_booking(
        '7372514319381',
        email: 'test@example.com',
        customer_ip: '127.0.0.1'
      )

      expect(response).to be_kind_of(Hash)
      expect(response).to have_key('itinerary_id')
      expect(response['itinerary_id']).to eq('7372514319381')
      expect(response['links']).to have_key('cancel')
      expect(response['links']['cancel']['method']).to eq('DELETE')
      expect(response['email']).to eq('test@example.com')
    end

    it 'should return booking by email' do
      stub_request(
        :get,
        'https://test.ean.com/2.4/itineraries/7372514319381?token=ABDE34Tj&language=en-US'
      ).with(
        headers: {
          'Accept' => 'application/json',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Authorization' => EpsRapid.auth_header,
          'Content-Type' => 'application/json',
          'Host' => 'test.ean.com',
          'User-Agent' => 'Ruby',
          'Customer-Ip' => '127.0.0.1'
        }
      ).to_return(status: 200, body: File.read('spec/fixtures/booking_retrieved.txt'))

      response = EpsRapid::ManageBooking.retrieve_booking(
        '7372514319381',
        token: 'ABDE34Tj',
        customer_ip: '127.0.0.1'
      )

      expect(response).to be_kind_of(Hash)
      expect(response).to have_key('itinerary_id')
      expect(response['itinerary_id']).to eq('7372514319381')
      expect(response['links']).to have_key('cancel')
      expect(response['links']['cancel']['method']).to eq('DELETE')
      expect(response['email']).to eq('test@example.com')
    end

    it 'should return error if itinerary_id is invalid' do
      stub_request(
        :get,
        'https://test.ean.com/2.4/itineraries/73?token=ABDE34Tj&language=en-US'
      ).with(
        headers: {
          'Accept' => 'application/json',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Authorization' => EpsRapid.auth_header,
          'Content-Type' => 'application/json',
          'Host' => 'test.ean.com',
          'User-Agent' => 'Ruby',
          'Customer-Ip' => '127.0.0.1'
        }
      ).to_return(status: 400, body: File.read('spec/fixtures/retrieve_booking_invalid.txt'))

      expect do
        EpsRapid::ManageBooking.retrieve_booking(
          73,
          token: 'ABDE34Tj',
          customer_ip: '127.0.0.1'
        )
      end.to raise_error(EpsRapid::Exceptions::BadRequestError, 'Code: 400, Error: Itinerary id is invalid.')
    end
  end

  describe '#cancel_held_booking' do
    it 'should return 204 status' do
      stub_request(:delete, 'https://test.ean.com/2.4/itineraries/7562428514179?token=ABE3TYUj23')
        .with(
          headers: {
            'Accept' => 'application/json',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Authorization' => EpsRapid.auth_header,
            'Content-Type' => 'application/json',
            'Host' => 'test.ean.com',
            'User-Agent' => 'Ruby',
            'Customer-Ip' => '127.0.0.1'
          }
        ).to_return(status: 204)

      response = EpsRapid::ManageBooking.cancel_held_booking(
        'itineraries/7562428514179?token=ABE3TYUj23',
        customer_ip: '127.0.0.1'
      )

      expect(response).to include('Code: 204, No content')
    end
  end

  describe '#cancel_room' do
    it 'should return 204 status' do
      stub_request(
        :delete,
        'https://test.ean.com/2.4/itineraries/7372514319381/rooms/512dab07-c9b7-494c-a517-05763aed4768?token=QFlCEVhQR'
      ).with(
        headers: {
          'Accept' => 'application/json',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Authorization' => EpsRapid.auth_header,
          'Content-Type' => 'application/json',
          'Host' => 'test.ean.com',
          'User-Agent' => 'Ruby',
          'Customer-Ip' => '127.0.0.1'
        }
      ).to_return(status: 204)

      response = EpsRapid::ManageBooking.cancel_room(
        'itineraries/7372514319381/rooms/512dab07-c9b7-494c-a517-05763aed4768?token=QFlCEVhQR',
        customer_ip: '127.0.0.1'
      )

      expect(response).to include('Code: 204, No content')
    end
  end

  describe '#change_room' do
    it 'should return 204 status' do
      body = JSON.parse(File.read('spec/fixtures/change_room.json'))

      stub_request(
        :put,
        'https://test.ean.com/2.4/itineraries/7372514319381/rooms/512dab07-c9b7-494c-a517-05763aed4768?token=QFlCEVhQR'
      ).with(
        headers: {
          'Accept' => 'application/json',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Authorization' => EpsRapid.auth_header,
          'Content-Type' => 'application/json',
          'Host' => 'test.ean.com',
          'User-Agent' => 'Ruby',
          'Customer-Ip' => '127.0.0.1'
        },
        body: body.to_json
      ).to_return(status: 204)

      response = EpsRapid::ManageBooking.change_room(
        'itineraries/7372514319381/rooms/512dab07-c9b7-494c-a517-05763aed4768?token=QFlCEVhQR',
        body,
        customer_ip: '127.0.0.1'
      )

      expect(response).to include('Code: 204, No content')
    end
  end
end
