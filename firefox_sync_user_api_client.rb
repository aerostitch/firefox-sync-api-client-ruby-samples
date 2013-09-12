#!/usr/bin/env ruby

require "net/http"
require "uri"
require "digest/sha1"   # Required by encrypt_user_login() function
require "base32"        # requires to install gem base32

# Class that talks to the user service of the Firefox Sync API
# It also talks to the misc service as it is used by the user API
# Perhaps this last service will be in a separate class if needed one day
#
class Firefox_sync_user_api_client

    attr_reader :ff_srv_scheme, :ff_server, :ff_user_api_svc, :ff_misc_api_svc,
        :ff_user_api_version, :ff_misc_api_version, :user_login,
        :encrypted_login, :http_proxy_uri, :http_proxy_port, :http_proxy_user

    def initialize(user_login, http_proxy_uri = nil, http_proxy_port = 8080,
                        http_proxy_user = nil, http_proxy_password = nil)
        @ff_srv_scheme = 'https://'
        @ff_server = 'auth.services.mozilla.com'
        @ff_user_api_svc = 'user'
        @ff_misc_api_svc = 'misc'
        @ff_user_api_version = '1.0'
        @ff_misc_api_version = '1.0'
        @user_login = user_login.downcase()     # needed for encryption
        @encrypted_login = encrypt_user_login(@user_login)
        @http_proxy_uri = http_proxy_uri
        @http_proxy_port = http_proxy_port
        @http_proxy_user = http_proxy_user
        @http_proxy_password = http_proxy_password
    end
    
    # This function builds the final uri for the various user service functions
    # of Firefox sync API
    #
    def ff_user_api_build_uri(enc_username = @encrypted_login, command = '')
        uri_to_parse = "#@ff_srv_scheme#@ff_server/#@ff_user_api_svc/"+
                       "#@ff_user_api_version/#{enc_username}"
        uri_to_parse += "/#{command}" unless command == ''
        URI.parse(uri_to_parse)
    end

    # Builds the uri and processes the GET request for the user service
    # of Firefox sync API
    #
    def ff_user_api_proceed_get_request(ff_enc_username = @encrypted_login,
                                        ff_commands = '')
        # Gets the uri
        uri = ff_user_api_build_uri(ff_enc_username, ff_commands)
        # Proceed the GET request using a proxy if configured
        proceed_get_request(uri)
    end

    # This function checks if the given login exists on firefox sync
    # If no argument provided, the @user_login instance variable is checked
    #
    def login_exists?(ff_username = @user_login)
        enc_username = encrypt_user_login(ff_username)
        rsp = ff_user_api_proceed_get_request(enc_username,'')
        raise IOError, "HTTP return code: #{rsp.code}" unless rsp.code == '200'
        (rsp.body == '1') ? true : false
    end





    # ****************** Functions relative to misc service ******************

    # This function builds the final uri for the various misc service functions
    # of Firefox sync API
    #
    def ff_misc_api_build_uri(command)
        uri_to_parse = "#@ff_srv_scheme#@ff_server/#@ff_misc_api_svc/"+
                       "#@ff_misc_api_version/#{command}"
        URI.parse(uri_to_parse)
    end

    # Builds the uri and processes the GET request for the misc service
    # of Firefox sync API
    #
    def ff_misc_api_proceed_get_request(ff_commands = '')
        # Gets the uri
        uri = ff_misc_api_build_uri(ff_commands)
        # Proceed the GET request using a proxy if configured
        proceed_get_request(uri)
    end
 
    # Gets the captcha required for some user functionalities
    #
    def get_captcha()
        # The captcha will be required to create a user
        ff_api_svc = 'captcha_html'
        rsp = ff_misc_api_proceed_get_request(ff_api_svc)
        raise IOError, "HTTP return code: #{rsp.code}" unless rsp.code == '200'
        rsp.body
    end
    
    
    # ******************** Private functions definition ********************
    private

    # This function encrypts the provided login in the way
    # the firefox API expects to get it
    #
    def encrypt_user_login(login)
        Base32::encode(Digest::SHA1.digest(login.downcase())).downcase()
    end

    # This function processes the GET request
    # It should be private and used by the ff_ functions
    #
    def proceed_get_request(uri_to_get)
        # Proceed the GET request using a proxy if configured
        if(@http_proxy_uri.nil? or @http_proxy_uri.size == 0)
            http = Net::HTTP::new(uri_to_get.host, uri_to_get.port,
                @http_proxy_uri, @http_proxy_port,
                @http_proxy_user, @http_proxy_password)
        else
            http = Net::HTTP.new(uri_to_get.host, uri_to_get.port)
        end
        http.use_ssl = true if uri_to_get.scheme == 'https'
        http.request(Net::HTTP::Get.new(uri_to_get.request_uri))
    end
end

