#!/usr/bin/env ruby
# encoding: utf-8

require "uri"
require_relative './fsac_common.rb'
require_relative './fsac_usersvc.rb'

# Class that talks to the storage service of the Firefox Sync API
# It will deal with the v1.1 of the storage service as the 2.0 is not usable
# and will do only read only informations
#
# NOTE: The "FSAC" abreviation stands for "Firefox Sync Api Client".
#
class FSAC_storagesvc
    
    attr_reader :user_obj

    def initialize(user_login, user_password, http_proxy_uri = nil, http_proxy_port = 8080,
                        http_proxy_user = nil, http_proxy_password = nil)
        @tools = FSAC_common.new(http_proxy_uri, http_proxy_port,
                                 http_proxy_user, http_proxy_password)
        @user_pwd = user_password
        @user_obj = FSAC_usersvc.new(user_login, 
                                     http_proxy_uri, http_proxy_port,
                                     http_proxy_user, http_proxy_password)
        @node = @user_obj.get_weave_node().sub(/\/$/,'')
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

    # Builds the uri for the storage service of the API
    #
    def build_uri(command = '')
        uri_to_parse = @node +'/1.1/'+ @user_obj.encrypted_login
        uri_to_parse += "/#{command}" unless command == ''
        puts uri_to_parse
        URI.parse(uri_to_parse)
    end

    # Returns a hash of collections associated with the account,
    # along with the last modified timestamp for each collection.
    #
    # GET https://server/pathname/version/username/info/collections
    #
    def get_user_collections()
        uri = build_uri('info/collections')
        @tools.process_get_request(uri, @user_obj.encrypted_login, @user_pwd).body
    end

end

