#!/usr/bin/env ruby
# encoding: utf-8
#
# This scripts helps you to test the fsac_storagesvc.rb script
#
require_relative '../fsac_storagesvc.rb'

puts "Please provide the email to use for firefox sync: "
email = STDIN.gets.chomp()
puts "Please provide the password to use for firefox sync: "
pwd = STDIN.gets.chomp()
puts "Please provide the passphrase (aka recovery key) to use for firefox sync: "
passphrase = STDIN.gets.chomp()

ac = FSAC_storagesvc.new(email, pwd, passphrase)
puts "\n\n"
puts ac.get_collections_size()
puts "\n\n"
puts ac.get_collections_count()
puts "\n\n"
puts ac.get_user_quota()
puts "\n\n"
pcolz = ac.get_user_collections()
puts pcolz
puts "\n\n"
JSON.parse(pcolz).each do |pcol,tz|
  colz = ac.get_collection_info(pcol)
  puts "----> "+ pcol + "  "+ colz.to_s
  colz.each { |col| puts pcol + "  "+ col + "  "+ 
    ac.get_subcollection_info(pcol,col)} if pcol != 'crypto'
end
