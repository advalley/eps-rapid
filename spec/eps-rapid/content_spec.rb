# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EpsRapid::Content do
  before :all do
    EpsRapid.configure do |config|
      config.api_key      = 'mock-api-key'
      config.secret_key   = 'mock-api-secret'
      config.base_path    = 'https://test.ean.com/2.4'
      config.language     = 'en-US'
    end
  end

  describe '#content_list' do
    it 'should return content list' do
      stub_request(:get, 'https://test.ean.com/2.4/properties/content?property_id=12345&language=en-US')
        .with(
          headers: {
            'Accept' => 'application/json',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Authorization' => EpsRapid.auth_header,
            'Content-Type' => 'application/json',
            'Host' => 'test.ean.com',
            'User-Agent' => 'Ruby'
          }
        ).to_return(status: 200, body: File.read('spec/fixtures/content.txt'))

      response = EpsRapid::Content.content_list(property_id: '12345')

      expect(response).to be_kind_of(Hash)
      expect(response).to have_key('12345')
      expect(response['12345']['name']).to eq('Test Property Name')
    end

    it 'should return return exception if property_id is not integer' do
      stub_request(:get, 'https://test.ean.com/2.4/properties/content?property_id=test&language=en-US')
        .with(
          headers: {
            'Accept' => 'application/json',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Authorization' => EpsRapid.auth_header,
            'Content-Type' => 'application/json',
            'Host' => 'test.ean.com',
            'User-Agent' => 'Ruby'
          }
        ).to_return(status: 400, body: File.read('spec/fixtures/content_invalid.txt'))

      expect do
        EpsRapid::Content.content_list(property_id: 'test')
      end.to raise_error(
        EpsRapid::Exceptions::BadRequestError,
        'Code: 400, Error: All provided property_id query parameters must be numeric' \
        ' (contains only digits 0-9, with no other characters).'
      )
    end

    describe '#guest_review' do
      it 'should return guest review' do
        stub_request(:get, 'https://test.ean.com/2.4/properties/12345/guest-reviews?language=en-US')
          .with(
            headers: {
              'Accept' => 'application/json',
              'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'Authorization' => EpsRapid.auth_header,
              'Content-Type' => 'application/json',
              'Host' => 'test.ean.com',
              'User-Agent' => 'Ruby'
            }
          ).to_return(status: 200, body: File.read('spec/fixtures/guest_review.txt'))

        response = EpsRapid::Content.guest_review('12345')

        expect(response).to be_kind_of(Hash)
        expect(response).to have_key('verified')
        expect(response['verified']['recent']).to be_kind_of(Array)
      end
    end

    describe '#catalog_file' do
      it 'should return catalog file' do
        stub_request(:get, 'https://test.ean.com/2.4/files/properties/catalog?language=en-US')
          .with(
            headers: {
              'Accept' => 'application/json',
              'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'Authorization' => EpsRapid.auth_header,
              'Content-Type' => 'application/json',
              'Host' => 'test.ean.com',
              'User-Agent' => 'Ruby'
            }
          ).to_return(status: 200, body: File.read('spec/fixtures/catalog_file.txt'))

        response = EpsRapid::Content.catalog_file

        expect(response).to be_kind_of(Hash)
        expect(response).to have_key('method')
        expect(response).to have_key('href')
        expect(response).to have_key('expires')
        expect(URI.parse(response['href'])).to be_kind_of(URI::HTTPS)
      end
    end

    describe '#content_file' do
      it 'should return catalog file' do
        stub_request(:get, 'https://test.ean.com/2.4/files/properties/content?language=en-US')
          .with(
            headers: {
              'Accept' => 'application/json',
              'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'Authorization' => EpsRapid.auth_header,
              'Content-Type' => 'application/json',
              'Host' => 'test.ean.com',
              'User-Agent' => 'Ruby'
            }
          ).to_return(status: 200, body: File.read('spec/fixtures/content_file.txt'))

        response = EpsRapid::Content.content_file

        expect(response).to be_kind_of(Hash)
        expect(response).to have_key('method')
        expect(response).to have_key('href')
        expect(response).to have_key('expires')
        expect(URI.parse(response['href'])).to be_kind_of(URI::HTTPS)
      end
    end

    describe '#chains' do
      it 'should return catalog file' do
        stub_request(:get, 'https://test.ean.com/2.4/chains?language=en-US')
          .with(
            headers: {
              'Accept' => 'application/json',
              'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'Authorization' => EpsRapid.auth_header,
              'Content-Type' => 'application/json',
              'Host' => 'test.ean.com',
              'User-Agent' => 'Ruby'
            }
          ).to_return(status: 200, body: File.read('spec/fixtures/chains.txt'))

        response = EpsRapid::Content.chains

        expect(response).to be_kind_of(Hash)
      end
    end
  end
end
