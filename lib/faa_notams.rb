# frozen_string_literal: true

require_relative "faa_notams/version"
require_relative "faa_notams/service"

# FaaNotams - Ruby gem to interact with FAA's Notice to Airmen (NOTAM) API
# https://external-api.faa.gov/notamapi
#
# This gem provides access to FAA's NOTAM API, which contains real-time notification
# of any change in the National Airspace System (NAS).
module FaaNotams
  class Error < StandardError; end
  
  # Convenience method to create a new service instance
  # @param client_id [String] FAA API client ID
  # @param client_secret [String] FAA API client secret
  # @return [FaaNotams::Service] A new service instance
  def self.new(client_id = nil, client_secret = nil)
    Service.new(client_id, client_secret)
  end
end
