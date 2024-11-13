module RSalesloft
  class Config
    class << self
      attr_accessor :api_key
      attr_reader :redis_pool, :redis_key_for_max_credits, :redis_key_prefix_for_remaining_credits

      def configure(config)
        @api_key = config[:api_key]

        @redis_pool = config[:redis_pool]
        @redis_key_for_max_credits = config[:redis_key_for_max_credits] || "salesloft-api-ratelimit-max"
        @redis_key_prefix_for_remaining_credits = config[:redis_key_prefix_for_remaining_credits] || "salesloft-api-ratelimit-remaining-"
        self
      end

      def reset!
        @api_key = nil
      end
    end
  end
end