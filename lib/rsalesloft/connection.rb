require "faraday"
require "faraday_middleware"
require "json"

module RSalesloft
  class Connection 
    class << self
      def get(path, options = {})
        res = connection.get(path, options)
        {
          body: res.body,
          headers: res.headers
        }
      end
    
      def post(path, req_body)
        res = connection.post do |req|
          req.url(path)
          req.body = req_body
        end

        {
          body: res.body,
          headers: res.headers
        }
      end
    
      def put(path, options = {})
        res = connection.put(path, options)
        {
          body: res.body,
          headers: res.headers
        }
      end
    
      def delete(path, options = {})
        res = connection.delete(path, options)
        {
          body: res.body,
          headers: res.headers
        }
      end

      private

      def connection
        Faraday.new(url: "https://api.salesloft.com/v2", headers: {
          accept: 'application/json',
          'Authorization' => "Bearer #{RSalesloft::Config.api_key}"
        }) do |conn|
          conn.request :json
          conn.response :json
          conn.response   :logger
          conn.adapter Faraday.default_adapter
        end
      end
    end
  end
end