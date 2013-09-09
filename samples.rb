#!/usr/bin/env ruby

require "net/http"
require "uri"
# require "openssl"
require 'digest/sha1'
require "base32"

# Defining variables to build uri
$ff_server = 'auth.services.mozilla.com'

def get_captcha()
    # The captcha will be required to create a user
    ff_api_svc = 'misc'
    ff_api_version = '1.0'
    uri = URI.parse("https://#$ff_server/#{ff_api_svc}/#{ff_api_version}/captcha_html")
    # Proceed the request
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if uri.scheme = 'https'
    response = http.request(Net::HTTP::Get.new(uri.request_uri))
    puts response.code
    puts response.body
end

# BE CAREFULL! This does not seems to work yet!
# I have to test method used at:
# https://github.com/iivvoo/Firefox-sync-example/blob/master/client.py
# and
# https://github.com/mikerowehl/firefox-sync-client-php/blob/master/sync.php
# perhaps that would work
def encrypt_username(username)
    # require "digest/sha1"
    signature = Base32::encode(Digest::SHA1.hexdigest(username.downcase())).downcase()
    # # require "openssl"
    # sha_enc = OpenSSL::Digest::SHA1.new
    # sha_enc.update(username.downcase())
    # signature = Base32::encode(sha_enc.to_s).downcase()
    puts "[DEBUG] encrypted username = #{signature}"
    return signature
end

def ff_user_api_build_uri(cleartext_username, ff_further_instructions = '')
    # Defining variables to build uri
    # https://<server name>/<api path set>/<version>/<username>/<further instruction>
    ff_server = 'auth.services.mozilla.com'
    ff_api_svc = 'user'
    ff_api_version = '1.0'
    ff_username = encrypt_username(cleartext_username)
    if ff_further_instructions != ''
        uri = URI.parse("https://#{ff_server}/#{ff_api_svc}/#{ff_api_version}/#{ff_username}/#{ff_further_instructions}")
    else
        uri = URI.parse("https://#{ff_server}/#{ff_api_svc}/#{ff_api_version}/#{ff_username}")
    end
    puts uri
    return uri
end
def ff_user_api_proceed_get_request(ff_username, ff_further_instructions = '')
    # Gets the uri
    uri = ff_user_api_build_uri(ff_username, ff_further_instructions)
    # Proceed the GET request
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if uri.scheme = 'https'
    response = http.request(Net::HTTP::Get.new(uri.request_uri))
    return response
end

def check_username_exists(ff_username)
    response = ff_user_api_proceed_get_request(ff_username)
    puts response.code
    puts response.body
end


def test(ff_username)
    response = ff_user_api_proceed_get_request(ff_username, 'storage/crypto/keys')
    puts response.code
    puts response.body
end

# get_captcha()
check_username_exists('thetheo')
test('thetheo')
