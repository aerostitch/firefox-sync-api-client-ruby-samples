#!/usr/bin/env ruby
# encoding: utf-8
#
# Test class for the Firefox_sync_api_client class
# available at https://github.com/aerostitch/firefox-sync-api-client-ruby-samples
#
# Requires minitest gem. Installed by default with ruby on debian but
# you have to do a "sudo yum install rubygem-minitest" on fedora to install it
#
# NOTE: The "FSAC" abreviation stands for "Firefox Sync Api Client".
#
require 'test/unit'
require_relative '../fsac_usersvc.rb'

# This constant should be filled with a correct firefox sync login
FF_SYNC_LOGIN = '<put_your_email_here!>'

class FSAC_usersvc_test < Test::Unit::TestCase

    # As the proxy is optionnal, we test the constructor without proxy
    #
    def test_init_no_proxy()
        puts "[INFO] Testing constructor without proxy settings"
        user_name = 'HelliHello'
        encrypted_user_name = "zfb4oykz7gpe43qkesxjl7j2vn6dcd3u"

        empty_class = FSAC_usersvc.new(user_name)
        assert_equal(empty_class.ff_srv_scheme, 'https://')
        assert_equal(empty_class.ff_server, 'auth.services.mozilla.com')
        assert_equal(empty_class.ff_user_api_svc, 'user')
        assert_equal(empty_class.ff_misc_api_svc, 'misc')
        assert_equal(empty_class.ff_user_api_version, '1.0')
        assert_equal(empty_class.ff_misc_api_version, '1.0')
        assert_equal(empty_class.user_login, user_name.downcase())
        assert_equal(empty_class.encrypted_login, encrypted_user_name)
        assert_nil(empty_class.http_proxy_uri)
        assert_equal(empty_class.http_proxy_port, 8080)
        assert_nil(empty_class.http_proxy_user)
        # Ensures the proxy password is not available from outside the class
        assert_raise(NoMethodError){empty_class.http_proxy_password}
    end

    # Testing the constructor with an unauthentified proxy
    #
    def test_init_with_proxy_noauth()
        puts "[INFO] Testing constructor with non authenticated proxy"
        user_name = 'T@tIsAwsome!'
        encrypted_user_name = "pm6usd2gi2bsa545vvftssf6qaq6qswx"
        sample_proxy = "sample.proxy.com"
        sample_proxy_port = 8081

        empty_class = FSAC_usersvc.new(user_name, sample_proxy,
            sample_proxy_port)
        assert_equal(empty_class.ff_srv_scheme, 'https://')
        assert_equal(empty_class.ff_server, 'auth.services.mozilla.com')
        assert_equal(empty_class.ff_user_api_svc, 'user')
        assert_equal(empty_class.ff_misc_api_svc, 'misc')
        assert_equal(empty_class.ff_user_api_version, '1.0')
        assert_equal(empty_class.ff_misc_api_version, '1.0')
        assert_equal(empty_class.user_login, user_name.downcase())
        assert_equal(empty_class.encrypted_login, encrypted_user_name)
        assert_equal(empty_class.http_proxy_uri, sample_proxy)
        assert_equal(empty_class.http_proxy_port, sample_proxy_port)
        assert_nil(empty_class.http_proxy_user)
        # Ensures the proxy password is not available from outside the class
        assert_raise(NoMethodError){empty_class.http_proxy_password}
    end
    
    # Testing the constructor with an authentified proxy
    #
    def test_init_with_proxy_auth()
        puts "[INFO] Testing constructor with an authenticated proxy"
        user_name = 'AintGotNoName...'
        encrypted_user_name = "houa7wyenqyleyp4h36vn5vs7d7osyfr"
        sample_proxy = "sample.proxy.com"
        sample_proxy_port = 8081
        sample_proxy_user = "mydomain\\myuser"
        sample_proxy_pwd = "APrettyLittlePwd"

        empty_class = FSAC_usersvc.new(user_name, sample_proxy,
            sample_proxy_port, sample_proxy_user, sample_proxy_pwd)
        assert_equal(empty_class.ff_srv_scheme, 'https://')
        assert_equal(empty_class.ff_server, 'auth.services.mozilla.com')
        assert_equal(empty_class.ff_user_api_svc, 'user')
        assert_equal(empty_class.ff_misc_api_svc, 'misc')
        assert_equal(empty_class.ff_user_api_version, '1.0')
        assert_equal(empty_class.ff_misc_api_version, '1.0')
        assert_equal(empty_class.user_login, user_name.downcase())
        assert_equal(empty_class.encrypted_login, encrypted_user_name)
        assert_equal(empty_class.http_proxy_uri, sample_proxy)
        assert_equal(empty_class.http_proxy_port, sample_proxy_port)
        assert_equal(empty_class.http_proxy_user, sample_proxy_user)
        # Ensures the proxy password is not available from outside the class
        assert_raise(NoMethodError){empty_class.http_proxy_password}
    end

    # Checks that the login exists returns the right thing
    #
    def test_login_exists()
        puts "[INFO] Testing the login_exists? function"
        user_name = 'dummy_login_wont_work'

        ff_uac = FSAC_usersvc.new(user_name)
        
        puts "[INFO] Testing login_exists? without parameters"
        # Should take provided username as defaut
        assert(!(ff_uac.login_exists?))

        puts "[INFO] Testing login_exists? with a custom login"
        assert(ff_uac.login_exists?(FF_SYNC_LOGIN))
    end


    # Checks that the get_captcha returns correctly a page
    # containing a lint to the google captcha api
    #
    def test_get_captcha()
        puts "[INFO] Testing the get_captcha function"
        ff_uac = FSAC_usersvc.new('')
        assert_match('https://www.google.com/recaptcha/api', ff_uac.get_captcha())
    end

    # Checks that the get_weave_node returns a url
    # or an IOError if username not found
    #
    def test_get_weave_node()
        puts "[INFO] Testing the get_weave_node function"
        ff_uac = FSAC_usersvc.new(FF_SYNC_LOGIN)
        assert_match(/https:\/\/.*\.services\.mozilla\.com\//,ff_uac.get_weave_node())
        ff_uac = FSAC_usersvc.new('dummy_login')
        assert_raise( IOError ) { ff_uac.get_weave_node() }
    end

    def test_require_password_reset()
        puts "[INFO] Testing the require_password_reset function"
        # Incorrect of missing user
        ff_uac = FSAC_usersvc.new('dummy_login')
        assert_raise( IOError ) { ff_uac.require_password_reset() }
        # Incorrect captcha, that's the best we can do here
        ff_uac = FSAC_usersvc.new(FF_SYNC_LOGIN)
        assert_raise( IOError ) { ff_uac.require_password_reset() }
    end

    #TODO:
    # Write tests for:
    #  - ff_user_api_build_uri
    #  - ff_user_api_proceed_get_request
    #  - ff_misc_api_build_uri
    #  - ff_user_api_proceed_get_request
end

