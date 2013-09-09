#!/usr/bin/env ruby


require "net/http"
require "uri"

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

def check_username_exists() # Does not work for now!
    # Defining variables to build uri
    # https://<server name>/<api path set>/<version>/<username>/<further instruction>
    ff_api_svc = 'user'
    ff_api_version = '1.0'
    ff_username = 'thetheo'
    ff_further_instructions = ''
    # uri = URI.parse("https://#$ff_server/#{ff_api_svc}/#{ff_api_version}/#{ff_username}/#{ff_further_intructions}")
    uri = URI.parse("https://#$ff_server/#{ff_api_svc}/#{ff_api_version}/#{ff_username}")
    # Proceed the request
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if uri.scheme = 'https'
    response = http.request(Net::HTTP::Get.new(uri.request_uri))
    puts response.code
    puts response.body
end

# get_captcha()
check_username_exists()
