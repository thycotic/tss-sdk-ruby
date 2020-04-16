require 'json'
require 'faraday'
require 'logger'

##
# If we're in the +test+ environment just dump logs to Null
# Otherwise, use stdout
if ENV['test']
  $logger = Logger.new(IO::NULL)
else
  $logger = Logger.new(STDOUT)
end

##
# Invoked when the API returns an +API_AccessDenied+ error
class AccessDeniedException < StandardError; end;

class InvalidConfigurationException < StandardError; end;
class InvalidCredentialsException < StandardError; end;
class InvalidMethodTypeException < StandardError; end;
class UnrecognizedResourceException < StandardError; end;

class Server
  DEFAULT_URL_TEMPLATE = "https://%s.secretservercloud.%s/"
  DEFAULT_TLD = "com"
  DEFAULT_API_PATH_URI = "/api/v1"
  DEFAULT_TOKEN_PATH_URI = "/oauth2/token"

  # Initialize a +Server+ object with provided configuration.
  #
  # @param config [Hash]
  #   - username: ''
  #   - password: ''
  #   - tld: 'com'
  #   - api_path_uri: '/api/v1'
  #   - token_path_uri: '/oauth2/token'
  #   - tenant: ''
  #   - server_url: ''
  def initialize(config)
    @configuration = config.collect{|k,v| [k.to_s, v]}.to_h
    if @configuration['server_url'] == "" && @configuration['tenant'] == ""
      $logger.error("Either ServerURL or Tenant must be set")
      raise InvalidConfigurationException
    end

    if @configuration['username'].nil? || @configuration['password'].nil?
      $logger.error("Must provide username and password")
      raise InvalidConfigurationException
    end

    if @configuration['tld'].nil?
      @configuration['tld'] = DEFAULT_TLD
    end

    if @configuration['api_path_uri'].nil?
      @configuration['api_path_uri'] = DEFAULT_API_PATH_URI
    end
    @configuration['api_path_uri'].delete_suffix!("/")

    if @configuration['token_path_uri'].nil?
      @configuration['token_path_uri'] = DEFAULT_TOKEN_PATH_URI
    end
    @configuration['token_path_uri'].delete_suffix!("/")
  end

  # Helper method to access a resource via API
  #
  # @param method [String] HTTP Request Method
  # @param resource [String] The resource type to invoke
  # @param path [String] The API Path to request
  # @param parse_json [Boolean] Determine whether we want to return a hash, or raw output
  #
  # @return [Hash] - If +parse_json+, return Hash of JSON contents
  # @return [String] - Otherwise, return raw HTTP Response Body
  #
  # - +AccessDeniedException+ is raised if the server responds with an +API_AccessDenied+ error
  # - +InvalidMethodTypeException+ is raised if a method other than +["GET", "POST", "PUT", "DELETE"]+ is provided
  # - +UnrecognizedResourceException+ is raised if a resource other than +["secrets"]+ is requested
  def accessResource(method, resource, path, parse_json = true)
    unless ["GET", "POST", "PUT", "DELETE"].include?(method.upcase)
      $logger.error "Invalid request method: #{method}"
      raise InvalidMethodTypeException
    end

    unless ["secrets"].include? resource
      $logger.debug "unrecognized resource: #{resource}"
      raise UnrecognizedResourceException
    end

    accessToken = getAccessToken

    url = urlFor(resource, path)
    $logger.debug "Sending request to: #{url}"
    resp = Faraday.send(method.downcase, url) do | req |
      req.headers['Authorization'] = "Bearer #{accessToken}"

      if ["POST", "PUT"].include?(method.upcase)
        req.headers['Content-Type'] = 'application/json'
      end
    end

    data = resp.body

    return data unless parse_json

    begin
      hash = JSON.parse(data)

      if hash['errorCode'] == "API_AccessDenied"
        raise AccessDeniedException
      end
    rescue JSON::ParserError => e
      $logger.error "Error parsing JSON: #{e.to_s}"
      raise e
    end

    return hash
  end

  # Query API for OAuth token
  #
  # - +InvalidCredentialsException+ is returned if the provided credentials are not valid
  # 
  # @return [String]
  def getAccessToken
    grantRequest = {
      grant_type: 'password',
      username: @configuration['username'],
      password: @configuration['password']
    }

    url = urlFor("token")

    response = Faraday.post(
      url, 
      grantRequest
    )

    unless response.status == 200
      $logger.error "Unable to retrive credentials for username: #{@configuration['username']}"
      $logger.error "\t #{response.body}"
      raise InvalidCredentialsException
    end

    begin
      grant = JSON.parse(response.body)
      return grant['access_token']
    rescue JSON::ParserError => e
      $logger.error "Error parsing JSON: #{e.to_s}"
      raise e
    end
  end

  # Generate the URL for a specific request.
  # This factors in several configuration options including:
  # - +tenant+
  # - +server_url+
  # - +token_path_uri+
  # - +api_path_uri+
  #
  # @param resource [String] The specific API resource to request
  # @param path [String] The path to the resource
  #
  # @return [String] The generated URL for the request
  def urlFor(resource, path=nil)

    if @configuration['server_url'].nil? || @configuration['server_url'] == ""
      baseURL = sprintf(DEFAULT_URL_TEMPLATE, @configuration['tenant'], @configuration['tld']).delete_suffix("/")
    else
      baseURL = @configuration['server_url'].delete_suffix("/")
    end

    if resource == "token"
      return sprintf("%s/%s", baseURL, @configuration['token_path_uri'].delete_prefix("/"))
    end

    if path != "/"
      path = path.delete_prefix("/")
    end

    sprintf("%s/%s/%s/%s", baseURL, @configuration['api_path_uri'].delete_prefix("/"), resource.delete_suffix("/").delete_prefix("/"), path)
  end
  
end