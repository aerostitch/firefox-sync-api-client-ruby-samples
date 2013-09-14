#!/usr/bin/env ruby

require "uri"
require_relative './fsac_common.rb'

# Class that talks to the user service of the Firefox Sync API
# It also talks to the misc service as it is used by the user API
# Perhaps this last service will be in a separate class if needed one day
#
# NOTE: The "FSAC" abreviation stands for "Firefox Sync Api Client".
#
class FSAC_usersvc

    attr_reader :ff_srv_scheme, :ff_server, :ff_user_api_svc, :ff_misc_api_svc,
        :ff_user_api_version, :ff_misc_api_version, :user_login, :encrypted_login

    def initialize(user_login, http_proxy_uri = nil, http_proxy_port = 8080,
                        http_proxy_user = nil, http_proxy_password = nil)
        @ff_srv_scheme = 'https://'
        @ff_server = 'auth.services.mozilla.com'
        @ff_user_api_svc = 'user'
        @ff_misc_api_svc = 'misc'
        @ff_user_api_version = '1.0'
        @ff_misc_api_version = '1.0'
        @tools = FSAC_common.new(http_proxy_uri, http_proxy_port,
                                 http_proxy_user, http_proxy_password)
        @user_login = user_login.downcase()     # needed for encryption
        @encrypted_login = @tools.encrypt_user_login(@user_login)
    end

    # Defining getters for encapsulated FSA_common attributes
    #
    def http_proxy_uri
        @tools.http_proxy_url
    end

    def http_proxy_port
        @tools.http_proxy_port
    end

    def http_proxy_user
        @tools.http_proxy_user
    end
    
    # This function builds the final uri for the various user service functions
    # of Firefox sync API
    #
    def ff_user_api_build_uri(enc_username = @encrypted_login, command = '')
        uri_to_parse = "#@ff_srv_scheme#@ff_server/#@ff_user_api_svc/"+
                       "#@ff_user_api_version/#{enc_username}"
        uri_to_parse += "/#{command}" unless command == ''
        URI.parse(uri_to_parse)
    end

    # Builds the uri and processes the GET request for the user service
    # of Firefox sync API
    #
    def ff_user_api_proceed_get_request(ff_enc_username = @encrypted_login,
                                        ff_commands = '')
        # Gets the uri
        uri = ff_user_api_build_uri(ff_enc_username, ff_commands)
        # Proceed the GET request using a proxy if configured
        @tools.process_get_request(uri)
    end

    # This function checks if the given login exists on firefox sync
    # If no argument provided, the @user_login instance variable is checked
    #
    def login_exists?(ff_username = @user_login)
        enc_username = @tools.encrypt_user_login(ff_username)
        rsp = ff_user_api_proceed_get_request(enc_username,'')
        raise IOError, "HTTP return code: #{rsp.code}" unless rsp.code == '200'
        (rsp.body == '1') ? true : false
    end

    # Gets the node Sync node that the client is located on.
    # Sync-specific calls should be directed to that node.
    #
    # Return value: the node URL, an unadorned (not JSON) string.
    #
    # node may be ‘null’ if no node can be assigned at this time,
    # probably due to sign up throttling.
    #
    def get_weave_node()
        rsp = ff_user_api_proceed_get_request(@encrypted_login,'node/weave')
        unless rsp.code == '200'
            err_msg = "HTTP return code: #{rsp.code}"
            err_msg += " (Mozilla didn't find the node)" if rsp.code == '503'
            err_msg += " (User not found)" if rsp.code == '404'
            raise IOError, err_msg
        end
        raise IOError, "Mozilla signing servers too busy" if rsp.body == 'null'
        rsp.body
    end

    # Requests a password reset email be mailed to the email address on file.
    # Returns 'success' if an email was successfully sent.
    # 
    # If captchas are enabled for the site, requires captcha-challenge 
    # and captcha-response parameters.
    #
    def require_password_reset()
        rsp = ff_user_api_proceed_get_request(@encrypted_login,'password_reset')
        unless rsp.code == '200'
            err_msg = "HTTP return code: #{rsp.code}"
            err_msg += " (problems with looking up the user 
                or sending the email)" if rsp.code == '503'
            if rsp.code == '400'
                if (@tools.fsac_resp_codes).has_key?(rsp.body)
                    err_msg += " ("+ @tools.fsac_resp_codes[rsp.body] +")"
                end
            end
            raise IOError, err_msg
        end
        raise IOError, "API returned #{rsp.body}" unless rsp.body == 'success'
        rsp.body 
    end


    # ****************** Functions relative to misc service ******************

    # This function builds the final uri for the various misc service functions
    # of Firefox sync API
    #
    def ff_misc_api_build_uri(command)
        uri_to_parse = "#@ff_srv_scheme#@ff_server/#@ff_misc_api_svc/"+
                       "#@ff_misc_api_version/#{command}"
        URI.parse(uri_to_parse)
    end

    # Builds the uri and processes the GET request for the misc service
    # of Firefox sync API
    #
    def ff_misc_api_proceed_get_request(ff_commands = '')
        # Gets the uri
        uri = ff_misc_api_build_uri(ff_commands)
        # Proceed the GET request using a proxy if configured
        @tools.process_get_request(uri)
    end

    # Gets the captcha required for some user functionalities
    #
    def get_captcha()
        # The captcha will be required to create a user
        ff_api_svc = 'captcha_html'
        rsp = ff_misc_api_proceed_get_request(ff_api_svc)
        raise IOError, "HTTP return code: #{rsp.code}" unless rsp.code == '200'
        rsp.body
    end
    
end

