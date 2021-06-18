# frozen_string_literal: true

module MyInfo
  module V4
    # Calls the Person API
    class EntityPerson < Api
      attr_accessor :access_token, :decoded_token, :attributes, :txn_no

      def initialize(access_token:, txn_no: nil, attributes: nil)
        @access_token = access_token
        @decoded_token = decode_jws(access_token)
        @attributes = Attributes.parse(attributes)
        @txn_no = txn_no
      end

      def call
        super do
          headers = header(params: params, access_token: access_token)
          endpoint_url = "/#{slug}?#{params.to_query}"

          # pp '***'
          # pp headers
          # pp '---'
          # pp endpoint_url
          # pp '***'

          response = http.request_get(endpoint_url, headers)
          parse_response(response)
        end
      end

      def slug
        slug_prefix = 'biz'

        "#{slug_prefix}/v2/entity-person/#{sub.split('_')[0]}/#{sub.split('_')[1]}"
      end

      def support_gzip?
        true
      end

      def params
        {
          txnNo: txn_no,
          attributes: attributes,
          client_id: config.biz_client_id,
        }.compact
      end

      def sub
        decoded_token['sub']
      end

      def errors
        %w[401 403 404]
      end

      def parse_response(response)
        super do
          json = decrypt_jwe(response.body)
          json = decode_jws(json.delete('"')) unless config.sandbox?

          Response.new(success: true, data: json)
        end
      end
    end
  end
end
