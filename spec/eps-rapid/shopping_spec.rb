# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EpsRapid::Shopping do
  before :all do
    EpsRapid.configure do |config|
      config.api_key      = 'mock-api-key'
      config.secret_key   = 'mock-api-secret'
      config.base_path    = 'https://test.ean.com/2.4'
      config.language     = 'en-US'
    end
  end

  describe '#availability' do
    it 'should return availability details' do
      stub_request(
        :get,
        'https://test.ean.com/2.4/properties/availability?occupancy=2-9,4&property_id=12345&country_code=US'\
        '&sales_environment=hotel_package&sales_channel=website&checkin=2021-05-01&checkout=2021-05-03&'\
        'currency=USD&rate_plan_count=1&language=en-US'
      ).with(
        headers: {
          'Accept' => 'application/json',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Authorization' => EpsRapid.auth_header,
          'Content-Type' => 'application/json',
          'Host' => 'test.ean.com',
          'User-Agent' => 'Ruby'
        }
      ).to_return(status: 200, body: File.read('spec/fixtures/availability.txt'))

      response = EpsRapid::Shopping.availability(
        occupancy: '2-9,4', property_id: '12345',
        country_code: 'US', sales_environment: 'hotel_package',
        sales_channel: 'website', checkin: '2021-05-01',
        checkout: '2021-05-03', currency: 'USD', rate_plan_count: '1'
      )

      expect(response).to be_kind_of(Array)
      expect(response.first).to have_key('property_id')
      expect(response.first).to have_key('rooms')
      expect(response.first['rooms']).to be_kind_of(Array)
      expect(response.first['property_id']).to eq('12345')
    end

    it 'should return exception if required params are missed' do
      stub_request(
        :get,
        'https://test.ean.com/2.4/properties/availability?occupancy=2-9,4&property_id=12345&country_code=US'\
        '&sales_environment=hotel_package&sales_channel=website&'\
        'currency=USD&rate_plan_count=1&language=en-US'
      ).with(
        headers: {
          'Accept' => 'application/json',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Authorization' => EpsRapid.auth_header,
          'Content-Type' => 'application/json',
          'Host' => 'test.ean.com',
          'User-Agent' => 'Ruby'
        }
      ).to_return(status: 400, body: File.read('spec/fixtures/availability_invalid.txt'))

      expect do
        EpsRapid::Shopping.availability(
          occupancy: '2-9,4', property_id: '12345',
          country_code: 'US', sales_environment: 'hotel_package',
          sales_channel: 'website', currency: 'USD', rate_plan_count: '1'
        )
      end.to raise_error(
        EpsRapid::Exceptions::BadRequestError,
        'Code: 400, Error: Checkout is required. Currency code is required.'
      )
    end
  end

  describe '#price_check' do
    it 'should return a booking link' do
      stub_request(
        :get,
        'https://test.ean.com/2.4/properties/12345/rooms/419495/rates/234264409?token=C~Oj46Zz8xJDEdYQQ'
      ).with(
        headers: {
          'Accept' => 'application/json',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Authorization' => EpsRapid.auth_header,
          'Content-Type' => 'application/json',
          'Host' => 'test.ean.com',
          'User-Agent' => 'Ruby'
        }
      ).to_return(status: 200, body: File.read('spec/fixtures/price_check.txt'))

      response = EpsRapid::Shopping.price_check('properties/12345/rooms/419495/rates/234264409?token=C~Oj46Zz8xJDEdYQQ')

      expect(response).to be_kind_of(Hash)
      expect(response['status']).to eq('available')
      expect(response['links']['book']['href']).to include('/2.4/itineraries')
    end

    it 'should return a link to additional rates' do
      stub_request(
        :get,
        'https://test.ean.com/2.4/properties/12345/rooms/419495/rates/234264409?token=C~Oj46Zz8xJDEdYQQ'
      ).with(
        headers: {
          'Accept' => 'application/json',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Authorization' => EpsRapid.auth_header,
          'Content-Type' => 'application/json',
          'Host' => 'test.ean.com',
          'User-Agent' => 'Ruby'
        }
      ).to_return(status: 200, body: File.read('spec/fixtures/price_changed.txt'))

      response = EpsRapid::Shopping.price_check('properties/12345/rooms/419495/rates/234264409?token=C~Oj46Zz8xJDEdYQQ')

      expect(response).to be_kind_of(Hash)
      expect(response['status']).to eq('price_changed')
      expect(response['links']['additional_rates']['href']).to include('/2.4/properties/19/availability')
    end
  end

  describe '#payment_options' do
    it 'should return a payment options' do
      stub_request(:get, 'https://test.ean.com/2.4/properties/12345/payment-options?token=REhZAQsABAM')
        .with(
          headers: {
            'Accept' => 'application/json',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Authorization' => EpsRapid.auth_header,
            'Content-Type' => 'application/json',
            'Host' => 'test.ean.com',
            'User-Agent' => 'Ruby'
          }
        ).to_return(status: 200, body: File.read('spec/fixtures/payment_options.txt'))

      response = EpsRapid::Shopping.payment_options('properties/12345/payment-options?token=REhZAQsABAM')

      expect(response).to be_kind_of(Hash)
      expect(response).to have_key('credit_card')
      expect(response['credit_card']['name']).to eq('Credit Card')
      expect(response['credit_card']['card_options'].count).to eq(8)
    end
  end

  describe '#deposit_policies' do
    it 'should return a deposite policies' do
      stub_request(:get, 'https://test.ean.com/2.4/properties/12345/deposit-policies?token=REhZAQsABAE')
        .with(
          headers: {
            'Accept' => 'application/json',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Authorization' => EpsRapid.auth_header,
            'Content-Type' => 'application/json',
            'Host' => 'test.ean.com',
            'User-Agent' => 'Ruby'
          }
        ).to_return(status: 200, body: File.read('spec/fixtures/deposit-policies.txt'))

      response = EpsRapid::Shopping.deposit_policies('properties/12345/deposit-policies?token=REhZAQsABAE')

      expect(response).to be_kind_of(Array)
      expect(response[0]).to have_key('nights')
      expect(response[1]).to have_key('amount')
    end
  end

  describe '#additional_rates' do
    it 'should return an additional rates' do
      stub_request(:get, 'https://test.ean.com/2.4/properties/12345/availability?token=REhZAQsABAMG')
        .with(
          headers: {
            'Accept' => 'application/json',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Authorization' => EpsRapid.auth_header,
            'Content-Type' => 'application/json',
            'Host' => 'test.ean.com',
            'User-Agent' => 'Ruby'
          }
        ).to_return(status: 200, body: File.read('spec/fixtures/additional_rates.txt'))

      response = EpsRapid::Shopping.additional_rates('properties/12345/availability?token=REhZAQsABAMG')

      expect(response).to be_kind_of(Array)
    end
  end

  describe '#recommendations' do
    it 'should return a recommendations list' do
      stub_request(:get, 'https://test.ean.com/2.4/properties/12345/availability?token=REhZAQsABAMCx')
        .with(
          headers: {
            'Accept' => 'application/json',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Authorization' => EpsRapid.auth_header,
            'Content-Type' => 'application/json',
            'Host' => 'test.ean.com',
            'User-Agent' => 'Ruby'
          }
        ).to_return(status: 200, body: File.read('spec/fixtures/additional_rates.txt'))

      response = EpsRapid::Shopping.recommendations('properties/12345/availability?token=REhZAQsABAMCx')

      expect(response).to be_kind_of(Array)
    end
  end
end
