#!/usr/bin/env ruby
#
# NOTE: The "FSAC" abreviation stands for "Firefox Sync Api Client".
#

require "net/http"
require "uri"
require "digest/sha1"   # Required by encrypt_user_login() function
require "base32"        # requires to install gem base32

# Enums used ot identify which http method to use
:http_head
:http_get
:http_post
:http_put
:http_delete
:http_trace

# This class contains functions that are common to the various services 
# of the Firefox Sync API
#
class FSAC_common

    attr_reader :http_proxy_url, :http_proxy_port, :http_proxy_user

    def initialize(http_proxy_url = nil, http_proxy_port = 8080,
                   http_proxy_user = nil, http_proxy_password = nil)
        @http_proxy_url = http_proxy_url
        @http_proxy_port = http_proxy_port
        @http_proxy_user = http_proxy_user
        @http_proxy_password = http_proxy_password
    end

    # This function encrypts the provided login in the way
    # the firefox API expects to get it
    #
    def encrypt_user_login(login)
        Base32::encode(Digest::SHA1.digest(login.downcase())).downcase()
    end

    # This function processes the GET request
    #
    def process_get_request(uri_to_get)
        process_http_request(:http_get, uri_to_get)
    end

    # This function processes the HTTP request
    #
    def process_http_request(http_method = :http_get, uri_to_get)
        # Process the HTTP request using a proxy if configured
        if(@http_proxy_url.nil? or @http_proxy_url.size == 0)
            http = Net::HTTP::new(uri_to_get.host, uri_to_get.port,
                @http_proxy_url, @http_proxy_port,
                @http_proxy_user, @http_proxy_password)
        else
            http = Net::HTTP.new(uri_to_get.host, uri_to_get.port)
        end
        http.use_ssl = true if uri_to_get.scheme == 'https'

        # Define which type of request will be processed
        if http_method = :http_get
            req_obj = Net::HTTP::Get.new(uri_to_get.request_uri)
        elsif http_method = :http_post
            req_obj = Net::HTTP::Post.new(uri_to_get.request_uri)
        elsif http_method = :http_put
            req_obj = Net::HTTP::Put.new(uri_to_get.request_uri)
        elsif http_method = :http_delete
            req_obj = Net::HTTP::Delete.new(uri_to_get.request_uri)
        elsif http_method = :http_head
            req_obj = Net::HTTP::Head.new(uri_to_get.request_uri)
        elsif http_method = :http_trace
            req_obj = Net::HTTP::Trace.new(uri_to_get.request_uri)
        else
            raise StandardError, "Unsupported HTTP method (#{http_method})"
        end

        http.request(req_obj)
    end

    # TODO:
    # Integrate response codes here
end

