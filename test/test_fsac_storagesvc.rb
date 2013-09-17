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
colz = ac.get_user_collections()
puts colz
puts "\n\n"
JSON.parse(colz).each do |col,tz|
  idx = ac.get_collection_index(col)
  puts "----> "+ col + "  "+ idx.to_s
  col.each { |item| puts col + "  "+ item + "  "+ 
    ac.get_item_data(col,item)} unless col == 'crypto'
end
