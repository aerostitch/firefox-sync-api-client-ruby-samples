#!/usr/bin/env ruby
# encoding: utf-8
#
# Test class for the FSAC_usersvc class
# available at https://github.com/aerostitch/firefox-sync-api-client-ruby-samples
#
# Requires minitest gem. Installed by default with ruby on debian but
# you have to do a "sudo yum install rubygem-minitest" on fedora to install it
#
# NOTE: The "FSAC" abreviation stands for "Firefox Sync Api Client".
#
require 'test/unit'
require_relative '../fsac_usersvc.rb'


class FSAC_usersvc_test < Test::Unit::TestCase

  @@user_login = nil
  @@cmptr = nil

  # This function is run befor each tests.
  # Here make the configuration only at 1st run
  def setup()
    # simulate a "startup" function (not available in my Test Unit version)
    if @@cmptr.nil?
      @@cmptr = 0 # Set to 0 at first run to make confiuration only once
      # Testing if not alread allocated.
      # This is usefull if you want to enter the informations manually first.
      if @@user_login.nil? or @@user_login.length == 0
        print "Please enter a valid firefox sync email account: "
        @@user_login = gets.chomp()
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
  end

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

    ff_uac = FSAC_usersvc.new(user_name, @@prox_ip, @@prox_port, @@prox_login, @@prox_pwd)
    
    puts "[INFO] Testing login_exists? without parameters"
    # Should take provided username as defaut
    assert(!(ff_uac.login_exists?))

    puts "[INFO] Testing login_exists? with a custom login"
    assert(ff_uac.login_exists?(@@user_login))
  end


  # Checks that the get_captcha returns correctly a page
  # containing a lint to the google captcha api
  #
  def test_get_captcha()
    puts "[INFO] Testing the get_captcha function"
    ff_uac = FSAC_usersvc.new('', @@prox_ip, @@prox_port, @@prox_login, @@prox_pwd)
    assert_match('https://www.google.com/recaptcha/api', ff_uac.get_captcha())
  end

  # Checks that the get_weave_node returns a url
  # or an IOError if username not found
  #
  def test_get_weave_node()
    puts "[INFO] Testing the get_weave_node function"
    ff_uac = FSAC_usersvc.new(@@user_login, @@prox_ip, @@prox_port, @@prox_login, @@prox_pwd)
    assert_match(/https:\/\/.*\.services\.mozilla\.com\//,ff_uac.get_weave_node())
    ff_uac = FSAC_usersvc.new('dummy_login', @@prox_ip, @@prox_port, @@prox_login, @@prox_pwd)
    assert_raise( IOError ) { ff_uac.get_weave_node() }
  end

  def test_require_password_reset()
    puts "[INFO] Testing the require_password_reset function"
    # Incorrect of missing user
    ff_uac = FSAC_usersvc.new('dummy_login', @@prox_ip, @@prox_port, @@prox_login, @@prox_pwd)
    assert_raise( IOError ) { ff_uac.require_password_reset() }
    # Incorrect captcha, that's the best we can do here for now
    ff_uac = FSAC_usersvc.new(@@user_login, @@prox_ip, @@prox_port, @@prox_login, @@prox_pwd)
    assert_raise( IOError ) { ff_uac.require_password_reset() }
  end

  #TODO:
  # Write tests for:
  #  - ff_user_api_build_uri
  #  - ff_user_api_proceed_get_request
  #  - ff_misc_api_build_uri
  #  - ff_user_api_proceed_get_request
end

