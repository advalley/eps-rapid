# frozen_string_literal: true

module EpsRapid
  class Content
    def self.content_list(**params)
      EpsRapid::Client.get('properties/content', params)
    end

    def self.guest_review(property_id)
      EpsRapid::Client.get("properties/#{property_id}/guest-reviews", {})
    end

    def self.catalog_file
      EpsRapid::Client.get('files/properties/catalog', {})
    end

    def self.content_file
      EpsRapid::Client.get('files/properties/content', {})
    end

    def self.chains
      EpsRapid::Client.get('chains', {})
    end
  end
end
