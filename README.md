firefox-sync-api-client-ruby-samples
====================================

The whole idea behind this is to finally have a complete class
for each API provided by firefox sync.

Requires ruby 1.9 minimum with base32 gem to work.

The "FSAC" abbreviation stands for "Firefox Sync Api Client".

Organization:
 * At the root level, one file for each class:
    * "fsac_usersvc.rb" is for the user service of the API
    * "fsac_common.rb" is for the functions used in multiple services of the API
    * "fsac_storagesvc.rb" is for the storage service of the API
 * In the "test" folder, the unit test files corresponding to the files 
   available at the root level
 * In the "examples" folder, you will find some scripts examples on how to use
   the classes exposed here.
 * The "Rakefile" only runs the unit tests
 * ".travis.yml" and "Gemfile" are used by travis-ci builds

NOTE: For people who would like to work on the version 2.0 of the storage
service of the sync API, you have to know that it is based on Sagrada. I had a
hard time looking for how it works and trying to find out why I couldn't find IP
for accessing https://directory.services.mozilla.com/discover . I finally
learned on IRC that Sanagra has never been released (I'm speaking now on
September, the 14th 2013) and stills stays as a specification. So it seems
useless trying to use this version 2.0 of the storage service of the API. :(

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

