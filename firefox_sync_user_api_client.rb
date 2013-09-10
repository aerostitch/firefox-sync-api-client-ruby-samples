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
        :encrypted_login

    def initialize(user_login)
        @ff_srv_scheme = 'https://'
        @ff_server = 'auth.services.mozilla.com'
        @ff_user_api_svc = 'user'
        @ff_misc_api_svc = 'misc'
        @ff_user_api_version = '1.0'
        @ff_misc_api_version = '1.0'
        @user_login = user_login.downcase()     # needed for encryption
        @encrypted_login = encrypt_user_login()
    end
    
    # This function encrypts the provided login in the way
    # the firefox API expects to get it
    def encrypt_user_login()
        return Base32::encode(Digest::SHA1.digest(@user_login)).downcase()
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
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true if uri.scheme == 'https'
        response = http.request(Net::HTTP::Get.new(uri.request_uri))
        puts response.code
        puts response.body
    end
    
    
    def ff_user_api_build_uri(cleartext_username, ff_further_instructions = '')
        # Defining variables to build uri
        # https://<server name>/<api path set>/<version>/<username>/<further instruction>
        uri_to_parse = "#@ff_srv_scheme#@ff_server/#@ff_user_api_svc/"+
            "#@ff_user_api_version/#@encrypted_login"
        if ff_further_instructions != ''
            uri_to_parse += "/#{ff_further_instructions}"
        end
        uri = URI.parse(uri_to_parse)
        puts uri
        return uri
    end
    def ff_user_api_proceed_get_request(ff_username, ff_further_instructions = '')
        # Gets the uri
        uri = ff_user_api_build_uri(ff_username, ff_further_instructions)
        # Proceed the GET request
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true if uri.scheme == 'https'
        response = http.request(Net::HTTP::Get.new(uri.request_uri))
        return response
    end
    
    def login_exists?(ff_username)
        response = ff_user_api_proceed_get_request(ff_username)
        puts response.code
        puts response.body
    end
    
    
    def test(ff_username)
        response = ff_user_api_proceed_get_request(ff_username, 'storage/crypto/keys')
        puts response.code
        puts response.body
    end
end

