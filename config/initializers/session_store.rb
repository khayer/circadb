# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
#ActionController::Base.session = {
#  :key         => '_circa_session',
#  :secret      => '6ddf20a7746e56de25ca2518fa2a21250b068e8f1b417787939d07772c9b228636efb417ad6613b93c4dfdd5953b2fb828f6931cccda6492f74e66f34ed6ed0d'
#}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store


# Be sure to restart your server when you modify this file.

Rails.application.config.session_store :cookie_store, key: '_test_rails_session'

