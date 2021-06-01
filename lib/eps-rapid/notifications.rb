# frozen_string_literal: true

module EpsRapid
  class Notifications
    def self.test_notification_event(event)
      EpsRapid::Client.get("notifications/#{event}", {})
    end

    def self.undeliverable_notifications
      EpsRapid::Client.get('notifications/undeliverable', {})
    end
  end
end
