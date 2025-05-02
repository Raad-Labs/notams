# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'

module FaaNotams
  # Service to interact with FAA's Notice to Airmen (NOTAM) API
  # https://external-api.faa.gov/notamapi
  #
  # This service provides access to FAA's NOTAM API, which contains real-time notification
  # of any change in the National Airspace System (NAS).
  class Service
    BASE_URL = "https://external-api.faa.gov/notamapi/v1"
    
    attr_reader :client_id, :client_secret

    # Initialize the service with FAA API credentials
    # @param client_id [String] FAA API client ID
    # @param client_secret [String] FAA API client secret
    def initialize(client_id = nil, client_secret = nil)
      @client_id = client_id || ENV['FAA_NOTAM_CLIENT_ID']
      @client_secret = client_secret || ENV['FAA_NOTAM_CLIENT_SECRET']
      
      raise ArgumentError, "FAA NOTAM client_id is required" unless @client_id
      raise ArgumentError, "FAA NOTAM client_secret is required" unless @client_secret
    end

    # =========================================================================
    # NOTAM API Endpoints
    # =========================================================================
    
    # Search for NOTAMs based on various criteria
    # @param options [Hash] Search criteria parameters
    # @option options [String] :response_format Format of the response ('aixm', 'geoJson', or 'aidap') (default: 'geoJson')
    # @option options [String] :icao_location ICAO location code (e.g., 'KIAD' for Dulles)
    # @option options [String] :domestic_location Domestic location code (e.g., 'IAD' for Dulles)
    # @option options [String] :notam_type The NOTAM type ('N' for New, 'R' for Replaced, or 'C' for Canceled)
    # @option options [String] :classification NOTAM classification ('INTL', 'MIL', 'DOM', 'LMIL', or 'FDC')
    # @option options [String] :notam_number The NOTAM number (e.g., 'CK0000/01')
    # @option options [String] :effective_start_date The effective start date (ISO 8601 format)
    # @option options [String] :effective_end_date The effective end date (ISO 8601 format)
    # @option options [String] :feature_type Feature type (e.g., 'RWY', 'TWY', 'AIRSPACE', etc.)
    # @option options [Float] :location_longitude Location longitude (e.g., -151.24)
    # @option options [Float] :location_latitude Location latitude (e.g., 60.57)
    # @option options [Float] :location_radius Location radius in nautical miles (max: 100nm)
    # @option options [String] :last_updated_date Last updated date (ISO 8601 format)
    # @option options [String] :sort_by Field to sort by (e.g., 'icaoLocation', 'effectiveStartDate')
    # @option options [String] :sort_order Sort order ('Asc' or 'Desc')
    # @option options [Integer] :page_size Number of results per page (max: 1000, default: 50)
    # @option options [Integer] :page_num Page number (default: 1)
    # @return [Hash] NOTAM search results
    def search(options = {})
      # Convert snake_case option keys to camelCase for the API
      params = {}
      
      # Handle response format separately (API expects 'responseFormat')
      if options[:response_format]
        params[:responseFormat] = validate_response_format(options[:response_format])
      end
      
      # Map option keys to API parameter names
      param_mapping = {
        icao_location: :icaoLocation,
        domestic_location: :domesticLocation,
        notam_type: :notamType,
        classification: :classification,
        notam_number: :notamNumber,
        effective_start_date: :effectiveStartDate,
        effective_end_date: :effectiveEndDate,
        feature_type: :featureType,
        location_longitude: :locationLongitude,
        location_latitude: :locationLatitude,
        location_radius: :locationRadius,
        last_updated_date: :lastUpdatedDate,
        sort_by: :sortBy,
        sort_order: :sortOrder,
        page_size: :pageSize,
        page_num: :pageNum
      }
      
      # Process each key and transform to camelCase for API
      param_mapping.each do |option_key, param_key|
        if options.key?(option_key)
          # Special validation for some parameters
          value = case option_key
          when :feature_type
            validate_feature_type(options[option_key])
          when :location_radius
            validate_range(options[option_key], 0.1, 100, 'location_radius')
          when :page_size
            validate_range(options[option_key], 1, 1000, 'page_size')
          when :page_num
            validate_range(options[option_key], 1, nil, 'page_num')
          when :sort_order
            validate_enum(options[option_key], %w[Asc Desc], 'sort_order')
          else
            options[option_key]
          end
          
          params[param_key] = value
        end
      end
      
      get("/search", params)
    end
    
    # Convenience method to search NOTAMs by airport code (ICAO or domestic)
    # @param airport_code [String] Airport code (e.g., 'KIAD' for ICAO or 'IAD' for domestic)
    # @param options [Hash] Additional search criteria
    # @return [Hash] NOTAM search results
    def search_by_airport(airport_code, options = {})
      airport_code = airport_code.to_s.upcase
      
      if airport_code.length == 3
        options[:domestic_location] = airport_code
      else
        options[:icao_location] = airport_code
      end
      
      search(options)
    end
    
    # Search NOTAMs by geographic location (latitude/longitude and radius)
    # @param latitude [Float] Location latitude
    # @param longitude [Float] Location longitude
    # @param radius [Float] Search radius in nautical miles (default: 50, max: 100)
    # @param options [Hash] Additional search criteria
    # @return [Hash] NOTAM search results
    def search_by_location(latitude, longitude, radius = 50, options = {})
      options[:location_latitude] = latitude
      options[:location_longitude] = longitude
      options[:location_radius] = radius
      
      search(options)
    end
    
    # Search for NOTAMs affecting a specific feature type
    # @param feature_type [String] Feature type (e.g., 'RWY', 'TWY', 'AIRSPACE', etc.)
    # @param options [Hash] Additional search criteria
    # @return [Hash] NOTAM search results
    def search_by_feature(feature_type, options = {})
      options[:feature_type] = validate_feature_type(feature_type)
      search(options)
    end

    # =========================================================================
    # Helper Methods
    # =========================================================================

    private

    # Make a GET request to the NOTAM API
    # @param path [String] API endpoint path
    # @param params [Hash] Query parameters
    # @return [Hash] Parsed JSON response
    def get(path, params = {})
      uri = URI.parse("#{BASE_URL}#{path}")
      uri.query = URI.encode_www_form(params) if params.any?
      
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      
      request = Net::HTTP::Get.new(uri)
      request['client_id'] = @client_id
      request['client_secret'] = @client_secret
      request['Accept'] = 'application/json'
      
      response = http.request(request)
      handle_response(response)
    end
    
    # Handle API response
    # @param response [Net::HTTPResponse] HTTP response from the API
    # @return [Hash] Parsed JSON response
    # @raise [RuntimeError] If the response is not successful
    def handle_response(response)
      case response.code.to_i
      when 200
        JSON.parse(response.body)
      when 400
        raise "Bad request: #{response.body}"
      when 401
        raise "Unauthorized: Invalid API credentials"
      when 404
        raise "Not found: Requested resource not available"
      when 500
        raise "Internal server error: #{response.body}"
      else
        raise "Unexpected response (#{response.code}): #{response.body}"
      end
    end
    
    # Validate response format
    # @param format [String] Format value to validate
    # @return [String] Validated format
    # @raise [ArgumentError] If format is not valid
    def validate_response_format(format)
      valid_formats = %w[aixm geoJson aidap]
      format = format.to_s.downcase
      
      # Special handling for 'geojson' vs 'geoJson' formats
      format = 'geoJson' if format == 'geojson'
      
      unless valid_formats.include?(format)
        raise ArgumentError, "Invalid response format. Must be one of: #{valid_formats.join(', ')}"
      end
      
      format
    end
    
    # Validate that a value is within a specific range
    # @param value [Numeric] Value to validate
    # @param min [Numeric] Minimum allowed value
    # @param max [Numeric] Maximum allowed value (or nil for no upper limit)
    # @param param_name [String] Parameter name for error messages
    # @return [Numeric] Validated value
    # @raise [ArgumentError] If value is not within range
    def validate_range(value, min, max, param_name)
      value = value.to_f
      if value < min || (max && value > max)
        max_msg = max ? " and #{max}" : ""
        raise ArgumentError, "Invalid #{param_name}. Must be between #{min}#{max_msg}."
      end
      value
    end
    
    # Validate that a value is within an enumeration
    # @param value [String] Value to validate
    # @param allowed_values [Array<String>] Allowed values
    # @param param_name [String] Parameter name for error messages
    # @return [String] Validated value
    # @raise [ArgumentError] If value is not in allowed values
    def validate_enum(value, allowed_values, param_name)
      value = value.to_s
      unless allowed_values.include?(value)
        raise ArgumentError, "Invalid #{param_name}. Must be one of: #{allowed_values.join(', ')}"
      end
      value
    end
    
    # Validate feature type
    # @param feature_type [String] Feature type to validate
    # @return [String] Validated feature type
    # @raise [ArgumentError] If feature type is not valid
    def validate_feature_type(feature_type)
      allowed_feature_types = %w[
        RWY TWY APRON AD OBST NAV COM SVC AIRSPACE ODP SID STAR 
        CHART DATA DVA IAP VFP ROUTE SPECIAL SECURITY MILITARY INTERNATIONAL
      ]
      
      validate_enum(feature_type, allowed_feature_types, 'feature_type')
    end
  end
end
