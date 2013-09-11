#!/usr/bin/env ruby

require "net/http"
require "uri"
require "digest/sha1"   # Required by encrypt_user_login() function
require "base32"        # requires to install gem base32

# TODO:
# I have to test method used at:
# https://github.com/iivvoo/Firefox-sync-example/blob/master/client.py
# and
# https://github.com/mikerowehl/firefox-sync-client-php/blob/master/sync.php

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
        @encrypted_login = encrypt_user_login()
        @http_proxy_uri = http_proxy_uri
        @http_proxy_port = http_proxy_port
        @http_proxy_user = http_proxy_user
        @http_proxy_password = http_proxy_password
    end
    
    # This function builds the uri to call for the various user API functions
    # of Firefox sync
    #
    def ff_user_api_build_uri(ff_further_instructions = '')
        uri_to_parse = "#@ff_srv_scheme#@ff_server/#@ff_user_api_svc/"+
                       "#@ff_user_api_version/#@encrypted_login"
        uri_to_parse += "/#{ff_further_instructions}" if ff_further_instructions != ''
        URI.parse(uri_to_parse)
    end

    # Build the uri and processes the GET request for the firefox user API
    def ff_user_api_proceed_get_request(ff_further_instructions = '')
        # Gets the uri
        uri = ff_user_api_build_uri(ff_further_instructions)
        # Proceed the GET request using a proxy if configured
        proceed_get_request(uri)
    end


    #
    # Functions bellow this point have not been completely adapted to a class structure
    #
    def get_captcha()
        # The captcha will be required to create a user
        ff_api_svc = "/captcha_html"
        uri_to_parse = "#@ff_srv_scheme#@ff_server/#@ff_misc_api_svc/"+
            "#@ff_misc_api_version#{ff_api_svc}"
        uri = URI.parse(uri_to_parse)
        # Proceed the request
        # if(@http_proxy_uri.nil? or @http_proxy_uri.size == 0)
        #     http = Net::HTTP::Proxy(uri.host, uri.port, @http_proxy_uri, @http_proxy_port)
        # else
            http = Net::HTTP.new(uri.host, uri.port)
        # end
        http.use_ssl = true if uri.scheme == 'https'
        response = http.request(Net::HTTP::Get.new(uri.request_uri))
        puts response.code
        puts response.body
    end
    
    
    def login_exists?(ff_username)
        response = ff_user_api_proceed_get_request()
        puts response.code
        puts response.body
    end
    
    
    def test(ff_username)
        response = ff_user_api_proceed_get_request(ff_username, 'storage/crypto/keys')
        puts response.code
        puts response.body
    end

    # ******************** Private functions definition ********************
    private

    # This function encrypts the provided login in the way
    # the firefox API expects to get it
    #
    def encrypt_user_login()
        Base32::encode(Digest::SHA1.digest(@user_login)).downcase()
    end

    # This function processes the GET request
    # It should be private and used by the ff_ functions
    #
    def proceed_get_request(uri_to_get)
        # Proceed the GET request using a proxy if configured
        if(@http_proxy_uri.nil? or @http_proxy_uri.size == 0)
            http = Net::HTTP::new(uri.host, uri.port, @http_proxy_uri, 
                    @http_proxy_port, @http_proxy_user, @http_proxy_password)
        else
            http = Net::HTTP.new(uri.host, uri.port)
        end
        http.use_ssl = true if uri.scheme == 'https'
        http.request(Net::HTTP::Get.new(uri.request_uri))
    end
end

