#!/usr/bin/env ruby
# encoding: utf-8

require 'uri'
require 'json'
require 'base64'
require 'base32'
require 'openssl'
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

  def initialize(user_login, user_password, passphrase,
                 http_proxy_uri = nil, http_proxy_port = 8080,
                 http_proxy_user = nil, http_proxy_password = nil)
    @tools = FSAC_common.new(http_proxy_uri, http_proxy_port,
                 http_proxy_user, http_proxy_password)
    @user_pwd = user_password
    @user_obj = FSAC_usersvc.new(user_login, 
                  http_proxy_uri, http_proxy_port,
                  http_proxy_user, http_proxy_password)
    @node = @user_obj.get_weave_node().sub(/\/$/,'')
    @encryption_key = encrypt_passphrase(passphrase)
    @priv_key = get_user_key()
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

  # Returns a hash of collections associated with the account, along with the
  # data volume used for each (in KB).
  #
  # GET https://server/pathname/version/username/info/collection_usage
  #
  def get_collections_size()
    uri = build_uri('info/collection_usage')
    @tools.process_get_request(uri, @user_obj.encrypted_login, @user_pwd).body
  end

  # Returns a hash of collections associated with the account, along with the
  # total number of items in each collection.
  #
  # GET https://server/pathname/version/username/info/collection_counts
  #
  def get_collections_count()
    uri = build_uri('info/collection_counts')
    @tools.process_get_request(uri, @user_obj.encrypted_login, @user_pwd).body
  end

  # Returns a list containing the user’s current usage and quota (in KB). The
  # second value will be null if no quota is defined.
  #
  # GET https://server/pathname/version/username/info/quota
  #
  def get_user_quota()
    uri = build_uri('info/quota')
    @tools.process_get_request(uri, @user_obj.encrypted_login, @user_pwd).body
  end
  
  # Returns a list of the WBO ids contained in a collection. This request has
  # additional optional parameters:
  #
  # ids: returns the ids for objects in the collection that are in the
  # provided comma-separated list.
  # predecessorid: returns the ids for objects in the collection that are
  # directly preceded by the id given. Usually only returns one result. [4]
  # parentid: returns the ids for objects in the collection that are the
  # children of the parent id given. [4]
  # older: returns only ids for objects in the collection that have been last
  # modified before the date given.
  # newer: returns only ids for objects in the collection that have been last
  # modified since the date given.
  # full: if defined, returns the full WBO, rather than just the id.
  # index_above: if defined, only returns items with a higher sortindex than
  # the value specified.
  # index_below: if defined, only returns items with a lower sortindex than
  # the value specified.
  # limit: sets the maximum number of ids that will be returned.
  # offset: skips the first n ids. For use with the limit parameter (required)
  # to paginate through a result set.
  # sort: sorts the output.
  # ‘oldest’ - Orders by modification date (oldest first)
  # ‘newest’ - Orders by modification date (newest first)
  # ‘index’ - Orders by the sortindex descending (highest weight first)
  # Two alternate output formats are available for multiple record GET
  # requests. They are triggered by the presence of the appropriate format in
  # the Accept header (with application/whoisi taking precedence):
  #
  # application/whoisi: each record consists of a 32-bit integer, defining the
  # length of the record, followed by the json record for a WBO
  # application/newlines: each record is a separate json object on its own
  # line. Newlines in the body of the json object are replaced by ‘u000a’
  # 
  # GET https://server/pathname/version/username/storage/collection
  #
  def get_collection_info(collection)
    uri = build_uri("storage/#{collection}")
    dat = @tools.process_get_request(uri, @user_obj.encrypted_login, @user_pwd).body
    eval(dat)
    # TODO:
    # - Play with the other options available
  end

  def get_subcollection_info(collection, id)
    uri = build_uri("storage/#{collection}/#{id}")
    ret = @tools.process_get_request(uri, @user_obj.encrypted_login, @user_pwd).body
    ret_hash = JSON.parse(ret)
    payload = JSON.parse(ret_hash['payload'])
    ciphertxt = Base64.decode64(payload['ciphertext'])
    iv = Base64.decode64(payload['IV'])
    decrypt_data(ciphertxt, @priv_key, iv)
  end

  # Function used to decrypt the data
  # and also used in the private key discovery process
  #
  def decrypt_data(data, private_key, iv)
    aes = OpenSSL::Cipher::AES.new(256, :CBC)
    aes.decrypt
    aes.iv = iv
    aes.key = private_key
    aes.update(data) + aes.final
  end

  # This function gets and decrypts the private key used to encrypt data
  #
  def get_user_key()
    uri = build_uri('storage/crypto/keys')
    ret = @tools.process_get_request(uri, @user_obj.encrypted_login, @user_pwd).body
    ret_hash = JSON.parse(ret)
    payload = JSON.parse(ret_hash['payload'])
    ciphertxt = Base64.decode64(payload['ciphertext'])
    iv = Base64.decode64(payload['IV'])
    priv_elts = JSON.parse(decrypt_data(ciphertxt, @encryption_key, iv))
    Base64.decode64(priv_elts['default'][0])
  end
  
  # This function is used to encrypt the passphrase to prepare it to decrypt
  # the data
  #
  def encrypt_passphrase(passphrase)
    digest = OpenSSL::Digest::SHA256.new
    intermdiate_pass = passphrase.gsub('-', '').gsub('8', 'l').gsub('9', 'o').upcase()
    pad = ((8 - intermdiate_pass.length % 8) % 8) + intermdiate_pass.length
    almost_final = intermdiate_pass.ljust(pad,'=')
    OpenSSL::HMAC.digest(digest, Base32::decode(almost_final), "Sync-AES_256_CBC-HMAC256" +
                         @user_obj.encrypted_login + "\x01")
  end
end

