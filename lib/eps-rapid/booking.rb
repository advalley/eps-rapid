# frozen_string_literal: true

module EpsRapid
  class Booking
    def self.register_payment(path, body, **params)
      EpsRapid::Client.post(path, body, params)
    end

    def self.create_booking(path, body, **params)
      EpsRapid::Client.post(path, body, params)
    end

    def self.resume_booking(path, **params)
      EpsRapid::Client.put(path, params)
    end

    def self.complete_payment_session(path, **params)
      EpsRapid::Client.put(path, params)
    end
  end
end
