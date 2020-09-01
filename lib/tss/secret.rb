
class InvalidSecretException < StandardError; end;

module Tss
  # Utilized to fetch secrets from an initialzed +Server+
  class Secret
    SECRETS_RESOURCE = "secrets".freeze
  
    # Fetch secrets from the server
    #
    # @param server [Server]
    #
    # @return [Hash] of the secret and associated file contents
    def self.fetch(server, id)
      @server = server
  
      begin
        @secret = @server.accessResource("GET", SECRETS_RESOURCE, id.to_s)
      rescue Exception => e
        $logger.error "Error accessing resource: #{e.to_s}"
        raise InvalidSecretException
      end

      raise InvalidSecretException if @secret.nil?

      #	automatically download file attachments and substitute them for the
      @secret['items'].each do |item|
        next if item['fileAttachmentId'].nil?

        path = sprintf("%d/fields/%s", id, item['slug'])
        
        item_data = @server.accessResource("GET", SECRETS_RESOURCE, path, false)

        item['itemValue'] = item_data
      end

      return @secret
    end
  end
end