# frozen_string_literal: true

module MyInfo
  module V4
    # Called after authorise to obtain a token for API calls
    class Token < Api
      attr_accessor :code, :state

      def initialize(code:, state: nil)
        @code = code
        @state = state
      end

      def call
        super do
          headers = header(params: params).merge({ 'Content-Type' => 'application/x-www-form-urlencoded' })

          response = http.request_post("/#{slug}", params.to_param, headers)

          parse_response(response)
        end
      end

      def http_method
        'POST'
      end

      def slug
        slug_prefix = 'biz'

        "#{slug_prefix}/v2/token"
      end

      def params
        {
          code: code,
          client_id: config.biz_client_id,
          client_secret: config.biz_client_secret,
          grant_type: 'authorization_code',
          redirect_uri: config.biz_redirect_uri
        }.compact
      end

      def errors
        %w[400 401]
      end

      def parse_response(response)
        super do
          json = JSON.parse(response.body)
          access_token = json['access_token']

          Response.new(success: true, data: access_token)
        end
      end
    end
  end
end
