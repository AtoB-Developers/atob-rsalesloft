require "faraday"
require "faraday_middleware"
require "json"

module RSalesloft
  class Connection 
    class << self
      def get(path, options = {})
        res = connection.get(path, options)

        update_remaining_credits(res.headers)
        res.body
      end
    
      def post(path, req_body)
        res = connection.post do |req|
          req.url(path)
          req.body = req_body
        end

        update_remaining_credits(res.headers)
        res.body
      end
    
      def put(path, options = {})
        res = connection.put(path, options)
        update_remaining_credits(res.headers)
        res.body
      end
    
      def delete(path, options = {})
        res = connection.delete(path, options)
        update_remaining_credits(res.headers)
        res.body
      end

      def remaining_credits
        redis_pool.with { |conn| (conn.get(redis_key_for_remaining_credits) || max_credits).to_i }
      end

      private

      def update_remaining_credits(headers)
        redis_pool.with do |conn|
          # Since there is a new key every minute, expiring a little later is okay since we won't hit this
          # key once the minute changes.
          conn.set(redis_key_for_remaining_credits, headers["x-ratelimit-remaining-minute"], ex: 65)
  
          # The max credits are more stable, only refresh once every day
          conn.set(RSalesloft::Config.redis_key_for_max_credits, headers["x-ratelimit-limit-minute"] || 600, ex: 1.day.to_i)
        end
      end

      def max_credits
        redis_pool.with { |conn| (conn.get(RSalesloft::Config.redis_key_for_max_credits) || 600).to_i }
      end

      def redis_pool
        RSalesloft::Config.redis_pool
      end

      def redis_key_for_remaining_credits
        # Salesloft ratelimits based on the current minute (X requests from 11:00:00.000 to 11:00:00.999) and
        # the limit is refreshed when the minute changes. This key returns the current minute.
        # 11th Nov 11:29 PM -> 2329
        "#{RSalesloft::Config.redis_key_prefix_for_remaining_credits}#{Time.current.strftime("%H%M")}"
      end

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