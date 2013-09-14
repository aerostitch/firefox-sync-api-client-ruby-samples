firefox-sync-api-client-ruby-samples
====================================

The whole idea behind this is to finally have a complete class
for each API provided by firefox sync.

Requires ruby 1.9 minimum with base32 gem to work.

The "FSAC" abreviation stands for "Firefox Sync Api Client".

Organization:
 * At the root level, one file for each class:
    * "firefox_sync_user_api_client.rb" is for the user service of the API
 * In the "test" folder, the unit test files corresponding to the files 
   available at the root level
 * The "Rakefile" only runs the unit tests
 * ".travis.yml" and "Gemfile" are used by travis-ci builds


Main resources:
 * API user service (aka registration service): https://docs.services.mozilla.com/reg/
 * API Storage service: https://docs.services.mozilla.com/storage/
 * Response codes common to all the services: https://docs.services.mozilla.com/respcodes.html
 * Sync client documentation: https://docs.services.mozilla.com/sync/index.html


NOTE:
As I am not an experienced programmer and that it's my first ruby scripts
if you have remarks on the code in a whole, please tell me!


Other interesting links:
 * python implementation of a client for this API: https://github.com/iivvoo/Firefox-sync-example/blob/master/client.py
 * php implementation of a client for this API: https://github.com/mikerowehl/firefox-sync-client-php/blob/master/sync.php

