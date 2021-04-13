# frozen_string_literal: true

module EpsRapid
  class Recommendations
    def self.recommendations(**params)
      EpsRapid::Client.get('properties/availability', params)
    end

    def self.alternative_recommendations(**params)
      EpsRapid::Client.get('properties/availability', params)
    end
  end
end
