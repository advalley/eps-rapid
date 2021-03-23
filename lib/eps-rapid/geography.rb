module EpsRapid
  class Geography
    def self.get_regions_list(ancestor_id = 0, includes = 'standard')
      includes = map_includes(includes)
      params = ["ancestor_id=#{ancestor_id}", includes].join('&')
      response = EpsRapid::Client.get('regions', params)
      JSON.parse(response.body)
    end

    def self.get_region(region_id, includes = 'details')
      params = map_includes(includes)
      response = EpsRapid::Client.get("regions/#{region_id}", params)
      JSON.parse(response.body)
    end

    def self.create_polygon(body)
      params = 'include=property_ids'
      body =
        {
          'type': 'Polygon',
          'coordinates': [body]
        }
      response = EpsRapid::Client.post('properties/geography', params, body)
      JSON.parse(response.body)
    end

    private

    def self.map_includes(includes)
      includes.gsub(' ', '').split(',').map { |el| "include=#{el}" }.join('&')
    end
  end
end