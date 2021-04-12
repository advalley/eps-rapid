# frozen_string_literal: true

module EpsRapid
  class Shopping
    def self.availability(**params)
      EpsRapid::Client.get('properties/availability', params)
    end

    def self.price_check(path, **params)
      EpsRapid::Client.get_by_link(path, params)
    end

    def self.payment_options(path, **params)
      EpsRapid::Client.get_by_link(path, params)
    end

    def self.deposit_policies(path, **params)
      EpsRapid::Client.get_by_link(path, params)
    end

    def self.additional_rates(path, **params)
      EpsRapid::Client.get_by_link(path, params)
    end
  end
end
