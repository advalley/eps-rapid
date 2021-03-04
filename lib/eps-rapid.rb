require 'eps-rapid/version'
require 'eps-rapid/geography'
require 'digest'

module EpsRapid
  class << self
    attr_accessor :api_key, :secret_key, :base_path

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
