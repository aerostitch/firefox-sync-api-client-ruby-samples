#!/usr/bin/env ruby
# encoding: utf-8
#
# Test class for the FSAC_storagesvc class available at
# https://github.com/aerostitch/firefox-sync-api-client-ruby-samples
#
# Requires minitest gem. Installed by default with ruby on debian but
# you have to do a "sudo yum install rubygem-minitest" on fedora to install it
#
# NOTE: The "FSAC" abreviation stands for "Firefox Sync Api Client".
#
require 'test/unit'
require 'json'
require_relative '../fsac_storagesvc.rb'

class FSAC_usersvc_test < Test::Unit::TestCase
  @@cmptr = nil
  # This function is run befor each tests.
  # Here make the configuration only at 1st run
  def setup()
    # simulate a "startup" function (not available in my Test Unit version)
    if @@cmptr.nil?
      @@cmptr = 0 # Set to 0 at first run to make confiuration only once
      print "Please provide the email to use for firefox sync: "
      @@email = STDIN.gets.chomp()
      print "Please provide the password to use for firefox sync: "
      @@pwd = STDIN.gets.chomp()
      print "Please provide the passphrase (aka recovery key) to use for firefox sync: "
      @@passphrase = STDIN.gets.chomp()
    end
  end

  # Testing get_user_quota function
  #
  def test_get_user_quota()
    puts "[INFO] Testing get_user_quota function"
    ac = FSAC_storagesvc.new(@@email, @@pwd, @@passphrase)
    assert_match(/^\[[0-9\.]+, (null|[0-9\.]+)\]$/, ac.get_user_quota())
  end

  # Testing get_collections_size function
  #
  def test_get_collections_size()
    puts "[INFO] Testing get_collections_size function"
    ac = FSAC_storagesvc.new(@@email, @@pwd, @@passphrase)
    col = JSON.parse(ac.get_collections_size())
    col.each{ |category, value| 
      assert(['addons', 'tabs', 'clients', 'crypto', 'bookmarks', 'prefs'].include?(category))
      assert(value.is_a?(Fixnum) || value.is_a?(Float))
    }
  end
end
# ac = FSAC_storagesvc.new(@@email, @@pwd, @@passphrase)
# puts "\n\n"
# puts ac.get_collections_size()
# puts "\n\n"
# puts ac.get_collections_count()
# puts "\n\n"
# colz = ac.get_user_collections()
# puts colz
# puts "\n\n"
# JSON.parse(colz).each do |col,tz|
#   idx = ac.get_collection_index(col)
#   puts "----> "+ col + "  "+ idx.to_s
#   col.each { |item| puts col + "  "+ item + "  "+ 
#     ac.get_item_data(col,item)} unless col == 'crypto'
# end
