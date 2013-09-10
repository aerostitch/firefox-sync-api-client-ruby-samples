#!/usr/bin/env ruby
#
# Test class for the Firefox_sync_api_client class
# available at https://github.com/aerostitch/firefox-sync-api-client-ruby-samples

require 'test/unit'
require_relative '../firefox_sync_user_api_client.rb'

class Ff_sync_user_api_client < Test::Unit::TestCase
    def test_init()
        user_name = 'HelliHello'
        encrypted_user_name = "zfb4oykz7gpe43qkesxjl7j2vn6dcd3u"
        empty_class = Firefox_sync_user_api_client.new(user_name)
        assert_equal(empty_class.ff_srv_scheme, 'https://')
        assert_equal(empty_class.ff_server, 'auth.services.mozilla.com')
        assert_equal(empty_class.ff_user_api_svc, 'user')
        assert_equal(empty_class.ff_misc_api_svc, 'misc')
        assert_equal(empty_class.ff_user_api_version, '1.0')
        assert_equal(empty_class.ff_misc_api_version, '1.0')
        assert_equal(empty_class.user_login, user_name.downcase())
        assert_equal(empty_class.encrypted_login, encrypted_user_name)
    end
end

