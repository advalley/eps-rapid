# frozen_string_literal: true

module EpsRapid
  class ManageBooking
    def self.retrieve_bookings(params)
      EpsRapid::Client.get('itineraries', params)
    end

    def self.retrieve_booking(itinerary_id, params)
      EpsRapid::Client.get("itineraries/#{itinerary_id}", params)
    end

    def self.cancel_held_booking(path, params)
      EpsRapid::Client.delete(path, params)
    end

    def self.cancel_room(path, params)
      EpsRapid::Client.delete(path, params)
    end

    def self.change_room(path, body, params)
      EpsRapid::Client.put(path, body, params)
    end
  end
end
