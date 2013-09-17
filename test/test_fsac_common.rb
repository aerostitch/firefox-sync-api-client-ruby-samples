#!/usr/bin/env ruby
# encoding: utf-8
#
# Test class for the FSAC_common class
# available at https://github.com/aerostitch/firefox-sync-api-client-ruby-samples
#
# Requires minitest gem. Installed by default with ruby on debian but
# you have to do a "sudo yum install rubygem-minitest" on fedora to install it
#
# NOTE: The "FSAC" abreviation stands for "Firefox Sync Api Client".
#
require 'test/unit'
require_relative '../fsac_common.rb'

class FSAC_common_test < Test::Unit::TestCase

  @@cmptr = nil

  # This function is run befor each tests.
  # Here make the configuration only at 1st run
  def setup()
    # simulate a "startup" function (not available in my Test Unit version)
    if @@cmptr.nil?
      @@cmptr = 0 # Set to 0 at first run to make confiuration only once
      print "Do you need a HTTP proxy to connect to internet? (y/n) [n]: "
      conf_proxy = gets.chomp()
      @@prox_ip = @@prox_port = @@prox_login = @@prox_pwd = nil
      if conf_proxy.downcase() == 'y'
        print "Please enter the HTTP proxy IP: "
        @@prox_ip = gets.chomp()
        print "Please enter the HTTP proxy port: "
        @@prox_port = gets.chomp()
        print "Please enter the HTTP proxy login (if any): "
        @@prox_login = gets.chomp()
        if @@prox_login.length == 0
          @@prox_login = nil
        else
          print "Please enter the HTTP proxy password (if any): "
          @@prox_pwd = gets.chomp()
        end
      end
    end
  end

  def test_get_moz_platform_status()
    ff_c = FSAC_common.new(@@prox_ip, @@prox_port, @@prox_login, @@prox_pwd)

    # get the XML data as a string
    status = ff_c.get_moz_platform_status
    assert_equal(status [0], "The Firefox Sync service is operating normally.")
    assert_equal(status[1], "There are no known problems at this time.")
  end
end
