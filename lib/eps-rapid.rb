require 'eps-rapid/version'
require 'eps-rapid/client'
require 'eps-rapid/errors/exceptions'
require 'eps-rapid/errors/http_status_codes'
require 'eps-rapid/geography'
require 'digest'

module EpsRapid
  class << self
    attr_accessor :api_key, :secret_key, :base_path, :language

    def configure
      yield(self)
    end

    def auth_header
      timestamp    = Time.now.to_i
      to_be_hashed = "#{self.api_key}#{self.secret_key}#{timestamp}"
      signature    = Digest::SHA2.new(512).hexdigest(to_be_hashed)
      auth_header  = "EAN apikey=#{self.api_key},signature=#{signature},timestamp=#{timestamp}"
    end
  end
end

EpsRapid.configure do |c|
  c.api_key = '21n6j1ea76vpnlffdi395cu311'
  c.secret_key = '64v9oo1mnonk5'
  c.base_path = 'https://test.ean.com/2.4'
  c.language = 'en-US'
end