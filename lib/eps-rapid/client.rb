# frozen_string_literal: true

require 'net/https'
require 'cgi'
require 'json'

module EpsRapid
  class Client
    class << self
      def get(path, params)
        uri = generate_uri(path, params)
        req = Net::HTTP::Get.new(uri)
        test_header, customer_ip_header = additional_headers(params)

        fetch_data(uri, req, test_header, customer_ip_header)
      end

      def post(path, body, params)
        uri = generate_uri(path, params)
        req = Net::HTTP::Post.new(uri)
        req.body = body.to_json
        test_header, customer_ip_header = additional_headers(params)

        fetch_data(uri, req, test_header, customer_ip_header)
      end

      def put(path, body = {}, params)
        uri = generate_uri(path, params)
        req = Net::HTTP::Put.new(uri)
        req.body = body.to_json

        test_header, customer_ip_header = additional_headers(params)

        fetch_data(uri, req, test_header, customer_ip_header)
      end

      def delete(path, params)
        uri = generate_uri(path, params)
        req = Net::HTTP::Delete.new(uri)
        test_header, customer_ip_header = additional_headers(params)

        fetch_data(uri, req, test_header, customer_ip_header)
      end

      private

      def generate_uri(path, params)
        uri = URI("#{EpsRapid.base_path}/#{path}")
        params.merge!({ language: EpsRapid.language })
        transformed_params = transform_params(params)
        transformed_params.reject { |k,_| k == :customer_ip }
        uri.query = URI.encode_www_form(transformed_params) unless path.include?('token')

        uri
      end

      def transform_params(params)
        params.each do |k, v|
          params[k] =
            if k == :occupancy
              v.to_s.tr(' ', '').split(';')
            else
              v.to_s.tr(' ', '').split(',')
            end
        end
      end

      def additional_headers(params)
        test_header = params.key?(:test) ? params[:test] : ''
        customer_ip_header = params.key?(:customer_ip) ? params[:customer_ip] : ''

        [test_header, customer_ip_header]
      end

      def fetch_data(uri, req, test_header, customer_ip)
        req['Authorization'] = EpsRapid.auth_header
        req['Accept'] = 'application/json'
        req['Content-Type'] = 'application/json'
        req['Customer-Ip'] = customer_ip if customer_ip != ''
        req['Test'] = test_header if test_header != ''

        response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(req) }

        case response.code.to_i
        when HttpStatusCodes::HTTP_OK_CODE, HttpStatusCodes::HTTP_CREATED_CODE
          JSON.parse(response.body)
        when HttpStatusCodes::HTTP_NO_CONTENT_CODE
          'Code: 204, No content'
        else
          raise error_class(response.code), "Code: #{response.code}, Error: #{map_error_messages(response.body)}"
        end
      end

      def error_class(code)
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
          Exceptions::EpsRapidError
        end
      end

      def map_error_messages(error_response)
        errors = []
        parsed_errors = JSON.parse(error_response)

        if parsed_errors['errors']&.any?
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
end
