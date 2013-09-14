#!/usr/bin/env ruby
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

    def test_get_moz_platform_status()
        ff_c = FSAC_common.new(nil, nil, nil, nil)

        # get the XML data as a string
        status = ff_c.get_moz_platform_status
        assert_equal(status [0], "The Firefox Sync service is operating normally.")
        assert_equal(status[1], "There are no known problems at this time.")
    end
end
