#!/usr/bin/env ruby
# encoding: utf-8
#
# NOTE: The "FSAC" abreviation stands for "Firefox Sync Api Client".
#

require "net/http"
require "uri"
require "digest/sha1"   # Required by encrypt_user_login() function
require "base32"    # requires to install gem base32

# Enums used to identify which http method to use
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
  attr_accessor :mozilla_status_url

  def initialize(http_proxy_url = nil, http_proxy_port = 8080,
          http_proxy_user = nil, http_proxy_password = nil)
    @http_proxy_url = http_proxy_url
    @http_proxy_port = http_proxy_port
    @http_proxy_user = http_proxy_user
    @http_proxy_password = http_proxy_password
    @mozilla_status_url = "https://services.mozilla.com/status/"
  end

  # Defining Firefox Sync API standard response code's corresponding friendly
  # human readable error message. Those response codes are sent by the API and
  # will be put in the body of the response.
  #
  @@fsac_resp_codes = {
    '1'  => 'Illegal method/protocol',
    '2'  => 'Incorrect/missing CAPTCHA',
    '3'  => 'Invalid/missing username',
    '4'  => "Attempt to overwrite data that can't be overwritten " +
        "(such as creating a user ID that already exists)",
    '5'  => 'User ID does not match account in path',
    '6'  => 'JSON parse failure',
    '7'  => 'Missing password field',
    '8'  => 'Invalid Weave Basic Object',
    '9'  => 'Requested password not strong enough',
    '10' => 'Invalid/missing password reset code',
    '11' => 'Unsupported function',
    '12' => 'No email address on file',
    '13' => 'Invalid collection',
    '14' => 'User over quota',
    '15' => 'The email does not match the username',
    '16' => 'Client upgrade required'
  }
 
  # Getter of the @@fsac_resp_codes hash
  def fsac_resp_codes
    @@fsac_resp_codes
  end

  # This function encrypts the provided login in the way
  # the firefox API expects to get it
  #
  def encrypt_user_login(login)
    Base32::encode(Digest::SHA1.digest(login.downcase())).downcase()
  end

  # Gets the status page of Mozilla services platform
  # Cannot be parsed using XML because Mozilla's web page does not
  # close properly its meta and div tags...
  #
  # Returns an array with the main title 1st and the explanations @2nd
  #
  def get_moz_platform_status()
    xml_data = process_get_request(URI.parse(@mozilla_status_url)).body
    extractor = /<div class="title">\s*(.*?)\s*<\/div>.*?<p>\s*(.*?)\s*<\/p>/m
    xml_data.scan(extractor)[0]
  end


  # This function processes the GET requests
  #
  def process_get_request(uri_to_get, auth_usr = nil, auth_pwd = nil)
    process_http_request(:http_get, uri_to_get, nil, auth_usr, auth_pwd)
  end

  # This function processes the HTTP request
  # content argument is used for put and post requests
  # auth_usr and auth_pwd are required for basic authentication
  # if auth_usr is nil, no authentication is done
  #
  def process_http_request(http_method = :http_get, uri_to_get = nil,
               content = nil, auth_usr = nil, auth_pwd = nil)
    # Process the HTTP request using a proxy if configured
    unless(@http_proxy_url.nil? or @http_proxy_url.size == 0)
      http = Net::HTTP::new(uri_to_get.host, uri_to_get.port,
        @http_proxy_url, @http_proxy_port,
        @http_proxy_user, @http_proxy_password)
    else
      http = Net::HTTP.new(uri_to_get.host, uri_to_get.port)
    end
    http.use_ssl = true if uri_to_get.scheme == 'https'

    # Define which type of request will be processed
    req_obj = case http_method
    when :http_get
      Net::HTTP::Get.new(uri_to_get.request_uri)
    when :http_post
      Net::HTTP::Post.new(uri_to_get.request_uri)
    when :http_put
      Net::HTTP::Put.new(uri_to_get.request_uri)
    when :http_delete
      Net::HTTP::Delete.new(uri_to_get.request_uri)
    when :http_head
      Net::HTTP::Head.new(uri_to_get.request_uri)
    when :http_trace
      Net::HTTP::Trace.new(uri_to_get.request_uri)
    end

    unless req_obj
      raise StandardError, "Unsupported HTTP method (#{http_method})"
    end

    req_obj.basic_auth(auth_usr, auth_pwd) unless auth_usr.nil?

    http.request(req_obj, content)
  end

end

