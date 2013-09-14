#!/usr/bin/env ruby
# encoding: utf-8

require "uri"
require_relative './fsac_common.rb'

# Class that talks to the storage service of the Firefox Sync API
# It will deal with the v2.0 of the storage service
# and will do only read only informations
#
# NOTE: The "FSAC" abreviation stands for "Firefox Sync Api Client".
#
class FSAC_storagesvc

    def initialize(user_login, http_proxy_uri = nil, http_proxy_port = 8080,
                        http_proxy_user = nil, http_proxy_password = nil)
        @tools = FSAC_common.new(http_proxy_uri, http_proxy_port,
                                 http_proxy_user, http_proxy_password)
        @user_login = user_login.downcase()     # needed for encryption
        @encrypted_login = @tools.encrypt_user_login(@user_login)
    end

    # Defining getters for encapsulated FSA_common attributes
    #
    def http_proxy_uri
        @tools.http_proxy_url
    end

    def http_proxy_port
        @tools.http_proxy_port
    end

    def http_proxy_user
        @tools.http_proxy_user
    end

end

