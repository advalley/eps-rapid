# frozen_string_literal: true

require 'eps-rapid/version'
require 'eps-rapid/client'
require 'eps-rapid/errors/exceptions'
require 'eps-rapid/errors/http_status_codes'
require 'eps-rapid/geography'
require 'eps-rapid/content'
require 'eps-rapid/shopping'
require 'eps-rapid/booking'
require 'eps-rapid/manage_booking'
require 'digest'

module EpsRapid
  class << self
    attr_accessor :api_key, :secret_key, :base_path, :language

    def configure
      yield(self)
    end

    def auth_header
      timestamp    = Time.now.to_i
      to_be_hashed = "#{api_key}#{secret_key}#{timestamp}"
      signature    = Digest::SHA2.new(512).hexdigest(to_be_hashed)
      "EAN apikey=#{api_key},signature=#{signature},timestamp=#{timestamp}"
    end
  end
end
