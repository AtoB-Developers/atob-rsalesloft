require "rsalesloft/config"
require "rsalesloft/connection"
require "rsalesloft/resources"

module RSalesloft
  def self.configure(config = {})
    RSalesloft::Config.configure(config)
  end

  def self.remaining_credits
    RSalesloft::Connection.remaining_credits
  end
end