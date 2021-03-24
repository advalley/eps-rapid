# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EpsRapid::Geography do
  before :all do
    EpsRapid.configure do |config|
      config.api_key      = 'mock-api-key'
      config.secret_key   = 'mock-api-secret'
      config.base_path    = 'https://test.ean.com/2.4'
      config.language     = 'en-US'
    end
  end

  describe '#get_regions_list' do
    it 'should return regions list' do
      stub_request(:get, 'https://test.ean.com/2.4/regions?include=standard&language=en-US')
        .with(
          headers: {
            'Accept' => 'application/json',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Authorization' => EpsRapid.auth_header,
            'Content-Type' => 'application/json',
            'Host' => 'test.ean.com',
            'User-Agent' => 'Ruby'
          }
        ).to_return(status: 200, body: File.read('spec/fixtures/regions.txt'))

      response = EpsRapid::Geography.regions_list

      expect(response).to be_kind_of(Array)
      expect(response.first).to have_key('id')
      expect(response.first).to have_key('name')
    end

    it 'should return exception if ancestor_id is not integer' do
      stub_request(:get, 'https://test.ean.com/2.4/regions?ancestor_id=ancestor&include=standard&language=en-US')
        .with(
          headers: {
            'Accept' => 'application/json',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Authorization' => EpsRapid.auth_header,
            'Content-Type' => 'application/json',
            'Host' => 'test.ean.com',
            'User-Agent' => 'Ruby'
          }
        ).to_return(status: 400, body: File.read('spec/fixtures/regions_invalid.txt'))

      expect do
        EpsRapid::Geography.regions_list(ancestor_id: 'ancestor')
      end.to raise_error(EpsRapid::Exceptions::BadRequestError, 'Code: 400, Error: Ancestor id must be numeric.')
    end
  end

  describe '#get_region' do
    it 'should return region with proper id' do
      stub_request(:get, 'https://test.ean.com/2.4/regions/2?include=details&language=en-US')
        .with(
          headers: {
            'Accept' => 'application/json',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Authorization' => EpsRapid.auth_header,
            'Content-Type' => 'application/json',
            'Host' => 'test.ean.com',
            'User-Agent' => 'Ruby'
          }
        ).to_return(status: 200, body: File.read('spec/fixtures/region.txt'))

      response = EpsRapid::Geography.region(2)

      expect(response['id']).to eq('2')
      expect(response['name']).to eq('Albania')
    end

    it 'should return exception if no region found' do
      stub_request(:get, 'https://test.ean.com/2.4/regions/1?include=details&language=en-US')
        .with(
          headers: {
            'Accept' => 'application/json',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Authorization' => EpsRapid.auth_header,
            'Content-Type' => 'application/json',
            'Host' => 'test.ean.com',
            'User-Agent' => 'Ruby'
          }
        ).to_return(status: 400, body: File.read('spec/fixtures/region_invalid.txt'))

      expect do
        EpsRapid::Geography.region(1)
      end.to raise_error(
        EpsRapid::Exceptions::BadRequestError,
        'Code: 400, Error: The requested region could not be found.'
      )
    end
  end

  describe '#create_polygon' do
    it 'should create a new polygon' do
      body = [
        [-93.446782, 37.169329],
        [-93.4244, 37.169432],
        [-93.371097, 37.168636],
        [-93.376295, 37.139236],
        [-93.361419, 37.138634],
        [-93.347109, 37.100601],
        [-93.215792, 37.095905],
        [-93.215259, 37.138013],
        [-93.189332, 37.141503],
        [-93.191278, 37.333322],
        [-93.438268, 37.339372],
        [-93.446782, 37.169329]
      ]
      stub_request(:post, 'https://test.ean.com/2.4/properties/geography?include=property_ids&language=en-US')
        .with(
          headers: {
            'Accept' => 'application/json',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Authorization' => EpsRapid.auth_header,
            'Content-Type' => 'application/json',
            'Host' => 'test.ean.com',
            'User-Agent' => 'Ruby'
          },
          body: {
            type: 'Polygon',
            coordinates: [body]
          }
        )
        .to_return(status: 200, body: '{
        "9261405": {"property_id": "9261405"},
        "1652868": {"property_id": "1652868"},
        "2774633": {"property_id": "2774633"},
        "22870": {"property_id": "22870"},
        "1373987": {"property_id": "1373987"},
        "891598": {"property_id": "891598"},
        "21988": {"property_id": "21988"},
        "22590856": {"property_id": "22590856"},
        "1090732": {"property_id": "1090732"},
        "2622": {"property_id": "2622"}
      }')

      response = EpsRapid::Geography.create_polygon(body)
      expect(response).to be_kind_of(Hash)
    end
  end
end
