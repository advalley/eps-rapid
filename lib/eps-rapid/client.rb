require 'net/https'
require 'json'

module EpsRapid
  class Client
    def self.get(path, params)
      params = params + "&language=#{EpsRapid.language}"
      encoded_uri = URI.encode("#{EpsRapid.base_path}/#{path}?#{params}")
      uri = URI.parse(encoded_uri)
      req = Net::HTTP::Get.new(uri)

      fetch_data(uri, req)
    end

    def self.post(path, params, body)
      params = params + "&language=#{EpsRapid.language}"
      encoded_uri = URI.encode("#{EpsRapid.base_path}/#{path}?#{params}")
      uri = URI.parse(encoded_uri)
      req = Net::HTTP::Post.new(uri)
      req.body = body.to_json

      fetch_data(uri, req)
    end

    private

    def self.fetch_data(uri, req)
      req['Authorization'] = EpsRapid.auth_header
      req['Accept'] = 'application/json'
      req['Content-Type'] = 'application/json'

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(req) }
      return response if response.code.to_i == HttpStatusCodes::HTTP_OK_CODE
      raise error_class(response.code), "Code: #{response.code}, Error: #{map_error_messages(response.body)}"
    end

    def self.error_class(code)
      case code.to_i
      when HttpStatusCodes::HTTP_BAD_REQUEST_CODE
        Exceptions::BadRequestError
      when HttpStatusCodes::HTTP_UNAUTHORIZED_CODE
        Exceptions::UnauthorizedError
      when HttpStatusCodes::HTTP_FORBIDDEN_CODE
        Exceptions::ForbiddenError
      when HttpStatusCodes::HTTP_NOT_FOUND_CODE
        Exceptions::NotFoundError
      when HttpStatusCodes::HTTP_SESSION_GONE_CODE
        Exceptions::SessionGoneError
      when HttpStatusCodes::HTTP_UPGRADE_REQUIRED_CODE
        Exceptions::UpgradeRequiredError
      when HttpStatusCodes::HTTP_TOO_MANY_REQUESTS_CODE
        Exceptions::TooManyRequestsError
      else
        Exceptions::EpsRapidApiError
      end
    end

    def self.map_error_messages(error_response)
      errors = []
      parsed_errors = JSON.parse(error_response)

      if !parsed_errors['errors'].nil?
        parsed_errors['errors'].each do |error|
          errors << error['message']
        end
        errors.join(' ')
      else
        parsed_errors['message']
      end
    end
  end
end