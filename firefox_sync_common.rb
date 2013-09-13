#!/usr/bin/env ruby

require "net/http"
require "uri"
require "digest/sha1"   # Required by encrypt_user_login() function
require "base32"        # requires to install gem base32

#
class Firefox_sync_common

    # This function encrypts the provided login in the way
    # the firefox API expects to get it
    #
    def Firefox_sync_common.encrypt_user_login(login)
        Base32::encode(Digest::SHA1.digest(login.downcase())).downcase()
    end

    # This function processes the GET request
    #
    def Firefox_sync_common.proceed_get_request(uri_to_get,
                    http_proxy_url = nil, http_proxy_port = nil,
                    http_proxy_user = nil, http_proxy_password = nil)
        # Proceed the GET request using a proxy if configured
        if(http_proxy_url.nil? or http_proxy_url.size == 0)
            http = Net::HTTP::new(uri_to_get.host, uri_to_get.port,
                http_proxy_url, http_proxy_port,
                http_proxy_user, http_proxy_password)
        else
            http = Net::HTTP.new(uri_to_get.host, uri_to_get.port)
        end
        http.use_ssl = true if uri_to_get.scheme == 'https'
        http.request(Net::HTTP::Get.new(uri_to_get.request_uri))
    end
end

