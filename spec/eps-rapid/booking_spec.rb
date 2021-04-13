# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EpsRapid::Booking do
  before :all do
    EpsRapid.configure do |config|
      config.api_key      = 'mock-api-key'
      config.secret_key   = 'mock-api-secret'
      config.base_path    = 'https://test.ean.com/2.4'
      config.language     = 'en-US'
    end
  end

  describe '#register_payment' do
    before(:each) do
      @body = JSON.parse(File.read('spec/fixtures/register_payment.json'))
    end

    it 'should return payment details' do
      stub_request(
        :post,
        'https://test.ean.com/2.4/payment-sessions?token=ABSDBV'
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
        body: @body.to_json
      ).to_return(status: 200, body: File.read('spec/fixtures/register_payment_response.txt'))

      response = EpsRapid::Booking.register_payment('payment-sessions?token=ABSDBV', @body, customer_ip: '127.0.0.1')

      expect(response).to be_kind_of(Hash)
      expect(response).to have_key('payment_session_id')
      expect(response).to have_key('encoded_init_config')
      expect(response['links']['book']['href']).to include('/2.4/itineraries')
    end

    it 'should return error if token not provided' do
      stub_request(:post, 'https://test.ean.com/2.4/payment-sessions?token=')
        .with(
          headers: {
            'Accept' => 'application/json',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Authorization' => EpsRapid.auth_header,
            'Content-Type' => 'application/json',
            'Host' => 'test.ean.com',
            'User-Agent' => 'Ruby',
            'Customer-Ip' => '127.0.0.1'
          },
          body: @body.to_json
        ).to_return(status: 400, body: File.read('spec/fixtures/register_payment_invalid.txt'))

      expect do
        EpsRapid::Booking.register_payment('payment-sessions?token=', @body, customer_ip: '127.0.0.1')
      end.to raise_error(EpsRapid::Exceptions::BadRequestError, 'Code: 400, Error: Link is invalid.')
    end
  end

  describe '#create_booking' do
    before(:each) do
      @body = JSON.parse(File.read('spec/fixtures/booking.json'))
    end

    it 'should return a link to reservation details' do
      stub_request(
        :post,
        'https://test.ean.com/2.4/itineraries/7562428514179?token=QldfCGlcUA4DVVhW'
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
        body: @body.to_json
      ).to_return(status: 200, body: File.read('spec/fixtures/booking_response.txt'))

      response = EpsRapid::Booking.create_booking(
        'itineraries/7562428514179?token=QldfCGlcUA4DVVhW',
        @body,
        customer_ip: '127.0.0.1'
      )

      expect(response).to be_kind_of(Hash)
      expect(response).to have_key('itinerary_id')
      expect(response['links']['retrieve']['href']).to include('/2.4/itineraries')
    end

    it 'should return error if request body is empty' do
      stub_request(:post, 'https://test.ean.com/2.4/itineraries?token=QldfCGlcUA4')
        .with(
          headers: {
            'Accept' => 'application/json',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Authorization' => EpsRapid.auth_header,
            'Content-Type' => 'application/json',
            'Host' => 'test.ean.com',
            'User-Agent' => 'Ruby',
            'Customer-Ip' => '127.0.0.1'
          },
          body: {}.to_json
        ).to_return(status: 400, body: File.read('spec/fixtures/booking_invalid.txt'))

      expect do
        EpsRapid::Booking.create_booking('itineraries?token=QldfCGlcUA4', {}, customer_ip: '127.0.0.1')
      end.to raise_error(EpsRapid::Exceptions::BadRequestError, 'Code: 400, Error: Payments is required.')
    end
  end

  describe '#resume_booking' do
    it 'should return 204 status' do
      stub_request(:put, 'https://test.ean.com/2.4/itineraries/7562428514179?token=ABE3TYUj23')
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

      response = EpsRapid::Booking.resume_booking(
        'itineraries/7562428514179?token=ABE3TYUj23',
        customer_ip: '127.0.0.1'
      )

      expect(response).to include('Code: 204, No content')
    end
  end

  describe '#complete_payment_session' do
    it 'should return a link to reservation details' do
      stub_request(:put, 'https://test.ean.com/2.4/itineraries/7562428514179/payment-sessions?token=ABE3TYUj23')
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
        ).to_return(status: 200, body: File.read('spec/fixtures/complete_payment_session_response.txt'))

      response = EpsRapid::Booking.complete_payment_session(
        'itineraries/7562428514179/payment-sessions?token=ABE3TYUj23',
        customer_ip: '127.0.0.1'
      )

      expect(response).to be_kind_of(Hash)
      expect(response).to have_key('itinerary_id')
      expect(response['links']['retrieve']['href']).to include('/2.4/itineraries')
    end
  end
end
