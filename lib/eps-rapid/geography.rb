# frozen_string_literal: true

module EpsRapid
  class Geography
    def self.get_regions_list(ancestor_id = 0, includes = 'standard')
      params = { ancestor_id: ancestor_id, include: map_includes(includes) }
      response = EpsRapid::Client.get('regions', params)
      JSON.parse(response.body)
    end

    def self.get_region(region_id, includes = 'details')
      params = { include: map_includes(includes) }
      response = EpsRapid::Client.get("regions/#{region_id}", params)
      JSON.parse(response.body)
    end

    def self.create_polygon(body)
      params = { include: 'property_ids' }
      body =
        {
          type: 'Polygon',
          coordinates: [body]
        }
      response = EpsRapid::Client.post('properties/geography', body, params)
      JSON.parse(response.body)
    end

    def self.map_includes(includes)
      includes.gsub(' ', '').split(',')
    end
  end
end
