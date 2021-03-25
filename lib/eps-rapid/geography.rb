# frozen_string_literal: true

module EpsRapid
  class Geography
    def self.regions_list(**params)
      params.merge!({ include: 'standard' }) if params[:include].nil?
      EpsRapid::Client.get('regions', params)
    end

    def self.region(region_id, **params)
      params.merge!({ include: 'details' }) if params[:include].nil?
      EpsRapid::Client.get("regions/#{region_id}", params)
    end

    def self.create_polygon(body)
      params = { include: 'property_ids' }
      body =
        {
          type: 'Polygon',
          coordinates: [body]
        }
      EpsRapid::Client.post('properties/geography', body, params)
    end

    def self.map_includes(includes)
      includes.gsub(' ', '').split(',')
    end
  end
end
